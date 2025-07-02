# syntax=docker/dockerfile:1

#######################
# Runtime-only image  #
#######################
FROM python:3.12-slim AS runtime

# ── Environment ────────────────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ── Security: create non-root user ────────────────────────────────────────
RUN adduser --disabled-password --gecos "" --uid 1001 adapter
WORKDIR /app

# ── Install Python deps ───────────────────────────────────────────────────
COPY fix-json-requirements.txt .
RUN pip install -r fix-json-requirements.txt

# ── Copy application code ────────────────────────────────────────────────
COPY fix-json-app.py .

USER adapter
EXPOSE 5000

ENTRYPOINT ["python", "fix-json-app.py"]

# docker build -f Dockerfile.fixjson -t brainupgrade/fix-json-adapter .
# docker run -d --name fix-json-adapter -p 5000:5000 --link risk-score:risk-score -e JSON_ENDPOINT="http://risk-score:8080/score" brainupgrade/fix-json-adapter