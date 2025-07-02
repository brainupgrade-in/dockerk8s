#!/usr/bin/env python3
"""
risk-core.py
────────────
A minimal in-memory risk-scoring service.

• Accepts POST /score  — JSON body produced by fix-json-adapter.
  ‣ Computes a deterministic risk_score from the payload.
  ‣ Stores (payload, risk_score) in memory.

• Serves  GET  /score  — Returns list of all stored risk scores.

Environment
-----------
LISTEN_PORT   TCP port to bind on (default: 8080)
"""

import hashlib
import json
import os
import threading
from typing import List, Dict, Any

from flask import Flask, request, jsonify, abort

LISTEN_PORT = int(os.getenv("LISTEN_PORT", "8080"))

app = Flask(__name__)

# ─────────────────────────── In-memory store (thread-safe) ──────────────────────────
_records: List[Dict[str, Any]] = []
_lock = threading.Lock()


def calc_risk_score(payload: Dict[str, Any]) -> int:
    """
    Very simple deterministic scoring: SHA-256 hash mod 100.
    Replace with real model/logic as needed.
    """
    blob = json.dumps(payload, sort_keys=True).encode()
    return int(hashlib.sha256(blob).hexdigest(), 16) % 100


# ─────────────────────────────────── API ─────────────────────────────────────────────
@app.route("/score", methods=["POST"])
def ingest_score():
    payload = request.get_json(silent=True)
    if payload is None:
        abort(400, description="Invalid or missing JSON body")

    score = calc_risk_score(payload)
    record = {"risk_score": score, "payload": payload}

    with _lock:
        _records.append(record)

    return jsonify(record), 200


@app.route("/score", methods=["GET"])
def list_scores():
    with _lock:
        return jsonify([{"risk_score": r["risk_score"]} for r in _records]), 200


# ─────────────────────────────────── Main ────────────────────────────────────────────
if __name__ == "__main__":
    print(f"Risk-scoring service listening on 0.0.0.0:{LISTEN_PORT}")
    app.run(host="0.0.0.0", port=LISTEN_PORT, threaded=True)
# This service is designed to be simple and stateless, suitable for demonstration purposes.
# In production, consider using a proper database for persistence and more complex risk scoring logic.
# Also, ensure proper error handling, logging, and security measures are in place.
# The Flask app runs in threaded mode to handle concurrent requests.
# For real-world applications, consider using a production WSGI server like Gunicorn or uvicorn.
# The risk score calculation is intentionally simple; replace it with your actual scoring logic.
# The in-memory store is thread-safe using a lock to prevent