#!/usr/bin/env python3
"""
risk-score.py
– Stores ⧉ FIX text, parsed JSON, and computed risk_score
– POST /score : ingest & persist
– GET  /score : list all records exactly as requested
"""

import hashlib, json, os, threading
from typing import Dict, Any, List
from flask import Flask, request, jsonify, abort

PORT = int(os.getenv("LISTEN_PORT", "8080"))
app  = Flask(__name__)

_records: List[Dict[str, Any]] = []
_lock = threading.Lock()


def calc_risk_score(data: Dict[str, Any]) -> int:
    blob = json.dumps(data, sort_keys=True).encode()
    return int(hashlib.sha256(blob).hexdigest(), 16) % 100


@app.route("/score", methods=["POST"])
def ingest():
    body = request.get_json(silent=True)
    if body is None:
        abort(400, "Invalid JSON")

    fix_raw   = body.get("fix_raw", "")
    json_data = body.get("json_data", body)          # fallback for older adapter
    score     = calc_risk_score(json_data)

    entry = {
        "fix_message": fix_raw,
        "json_message": json_data,
        "risk_score": score,
    }

    with _lock:
        _records.append(entry)
    return jsonify(entry), 200


@app.route("/score", methods=["GET"])
def list_scores():
    with _lock:
        return jsonify(_records), 200


if __name__ == "__main__":
    print(f"Risk-score service on 0.0.0.0:{PORT}")
    app.run(host="0.0.0.0", port=PORT, threaded=True)

# This service is designed to be simple and stateless, suitable for demonstration purposes.
# In production, consider using a proper database for persistence and more complex risk scoring logic.
# Also, ensure proper error handling, logging, and security measures are in place.
# The Flask app runs in threaded mode to handle concurrent requests.
# For real-world applications, consider using a production WSGI server like Gunicorn or uvicorn.
# The risk score calculation is intentionally simple; replace it with your actual scoring logic.
# The in-memory store is thread-safe using a lock to prevent