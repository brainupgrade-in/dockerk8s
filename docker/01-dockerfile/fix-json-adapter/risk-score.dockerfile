# syntax=docker/dockerfile:1

###############################################################################
#  Risk-Score Flask App                                                       #
#  Builds a lightweight image that serves risk-score.py on port 8080 (default)#
###############################################################################

FROM python:3.12-slim AS runtime

# ── Basic runtime tuning ──────────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ── Create non-root user for security ─────────────────────────────────────────
RUN adduser --disabled-password --gecos "" --uid 1001 appuser
WORKDIR /app

# ── Install Python dependencies ───────────────────────────────────────────────
COPY risk-score-requirements.txt .
RUN pip install --no-compile -r risk-score-requirements.txt

# ── Copy application code ─────────────────────────────────────────────────────
COPY risk-score.py .

USER appuser
EXPOSE 8080        
# default; overridden via LISTEN_PORT env var if desired

ENTRYPOINT ["python", "risk-score.py"]

# docker build -f risk-score.dockerfile -t brainupgrade/risk-score .
# docker run -d --name risk-score -p 8080:8080 brainupgrade/risk-score
