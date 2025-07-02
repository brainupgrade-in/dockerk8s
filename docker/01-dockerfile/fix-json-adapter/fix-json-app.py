#!/usr/bin/env python3
"""
FIX 4.4 ➜ JSON adapter.

Listens for FIX messages on TCP (default :5000), converts each complete message
to JSON, and HTTP-POSTs it to an endpoint (default http://localhost:8080/score).

• Listener port - env `FIX_LISTEN_PORT`  (int)
• POST URL      - env `JSON_ENDPOINT`   (str)

Dependencies: requests  (pip install requests)
"""

import json
import os
import re
import socketserver
import threading
from typing import Generator

import requests

SOH = b'\x01'          # FIX field separator (ASCII 0x01)

LISTEN_PORT = int(os.getenv("FIX_LISTEN_PORT", "5000"))
POST_URL = os.getenv("JSON_ENDPOINT", "http://localhost:8080/score")

# Regex locating checksum tag 10=###<SOH> (marks end of a FIX message)
CHK_RE = re.compile(rb'10=\d{3}\x01')

def split_fix_stream(buffer: bytearray) -> Generator[bytes, None, None]:
    """
    Incrementally yield complete FIX messages from the buffer.
    Removes each emitted message from the buffer.
    """
    while True:
        m = CHK_RE.search(buffer)
        if not m:
            break
        end = m.end()        # index after SOH
        yield bytes(buffer[:end])
        del buffer[:end]     # consume emitted message


def fix_to_dict(msg: bytes) -> dict:
    """
    Convert raw FIX bytes (8=...10=###\x01) to a Python dict.
    """
    fields = msg.rstrip(SOH).split(SOH)
    result = {}
    for field in fields:
        if not field:
            continue
        tag, _, value = field.partition(b'=')
        result[tag.decode()] = value.decode()
    return result


class FIXHandler(socketserver.StreamRequestHandler):
    """
    One handler per TCP connection (threaded).
    Accumulates bytes, detects full messages, posts JSON.
    """

    def handle(self) -> None:
        self.buffer = bytearray()
        while True:
            chunk = self.rfile.read(4096)
            if not chunk:
                break
            self.buffer.extend(chunk)
            for raw_msg in split_fix_stream(self.buffer):
                self.process_message(raw_msg)

    def process_message(self, raw_msg: bytes) -> None:
        try:
            fix_dict = fix_to_dict(raw_msg)
            response = requests.post(POST_URL, json=fix_dict, timeout=5)
            response.raise_for_status()
            self.log(f"Forwarded FIX msg (MsgType={fix_dict.get('35')}) ➜ {POST_URL} [{response.status_code}]")
        except Exception as e:
            self.log(f"ERROR processing message: {e}")

    def log(self, msg: str) -> None:
        client = f"{self.client_address[0]}:{self.client_address[1]}"
        print(f"[{threading.current_thread().name} {client}] {msg}")


class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True


def main() -> None:
    print(f"Listening for FIX 4.4 on 0.0.0.0:{LISTEN_PORT}")
    print(f"Posting JSON messages to {POST_URL}")
    with ThreadedTCPServer(("0.0.0.0", LISTEN_PORT), FIXHandler) as server:
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down.")


if __name__ == "__main__":
    main()
