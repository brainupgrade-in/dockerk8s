#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# test-fix-adapter.sh
#
# Usage: ./test-fix-adapter.sh  [adapter-image[:tag]]
#
# If no image is supplied, defaults to "fix-adapter:latest".
# ---------------------------------------------------------------------------
set -euo pipefail

IMAGE="${1:brainupgrade/fix-json-adapter:latest}"
FIX_PORT=5000
JSON_PORT=8080

# ── 1. Start a lightweight JSON echo server (background) ───────────────────
cat <<'PY' >/tmp/json_echo.py
import http.server, sys, json

class Echo(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        ln = int(self.headers.get('Content-Length', 0))
        payload = self.rfile.read(ln)
        print("\n=== JSON RECEIVED ===")
        print(payload.decode())
        self.send_response(200)
        self.end_headers()
    def log_message(self, *_):  # silence default logging
        pass

http.server.HTTPServer(("0.0.0.0", int(sys.argv[1])), Echo).serve_forever()
PY

python3 /tmp/json_echo.py "$JSON_PORT" &
ECHO_PID=$!
trap 'kill $ECHO_PID 2>/dev/null || true' EXIT

echo "[+] JSON echo server listening on localhost:$JSON_PORT"

# ── 2. Run the FIX-adapter container on the host network ───────────────────
docker run --rm -d --name fix-adapter-test \
  --network host \
  -e FIX_LISTEN_PORT="$FIX_PORT" \
  -e JSON_ENDPOINT="http://localhost:$JSON_PORT" \
  "$IMAGE"

echo "[+] Adapter container started (image: $IMAGE, FIX port: $FIX_PORT)"

# ── 3. Give container a moment to start up ─────────────────────────────────
sleep 2

# ── 4. Craft and send a sample FIX 4.4 message via netcat ─────────────────-
SOH=$'\x01'
FIX_MSG="8=FIX.4.4${SOH}9=65${SOH}35=0${SOH}49=SENDER${SOH}56=TARGET${SOH}34=1${SOH}52=20250702-20:00:00${SOH}10=000${SOH}"

echo "[+] Sending sample FIX message to localhost:$FIX_PORT"
printf '%s' "$FIX_MSG" | nc -w1 localhost "$FIX_PORT"

# ── 5. Wait briefly so adapter can forward the JSON ────────────────────────
sleep 2
echo "[+] Test complete — check the JSON payload above."

# Stop the container (trap will kill echo server)
docker stop fix-adapter-test >/dev/null
