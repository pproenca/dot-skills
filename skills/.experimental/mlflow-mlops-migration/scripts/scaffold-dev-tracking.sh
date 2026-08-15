#!/usr/bin/env bash
# scaffold-dev-tracking.sh — Write a local dev tracking stack (docker compose)
# Part of: mlflow-mlops-migration
#
# Writes docker-compose.mlflow-dev.yml (PostgreSQL backend + MLflow 3 tracking
# server with proxied artifacts) into the target directory. Refuses to overwrite.
# Nothing is started — starting the stack is a separate, user-confirmed step.
#
# Usage: scaffold-dev-tracking.sh <target-dir>
# Exit:  0 = written, 1 = bad arguments, 2 = already scaffolded (skipped)

set -euo pipefail

if [[ $# -lt 1 || ! -d "${1:-}" ]]; then
  echo "Usage: $0 <target-dir>" >&2
  echo "  <target-dir> must be an existing directory (usually the repo root)." >&2
  exit 1
fi

TARGET="$(cd "$1" && pwd)"
COMPOSE_FILE="$TARGET/docker-compose.mlflow-dev.yml"

if [[ -e "$COMPOSE_FILE" ]]; then
  echo "Already scaffolded: $COMPOSE_FILE exists — not overwriting." >&2
  echo "Delete it first if you want a fresh scaffold." >&2
  exit 2
fi

cat > "$COMPOSE_FILE" <<'YAML'
# Dev tracking stack for MLflow 3 — written by mlflow-mlops-migration.
# Postgres backend + tracking server with proxied artifact storage, mirroring
# the staging/prod topology (database + artifacts-destination) at laptop scale.
#
#   docker compose -f docker-compose.mlflow-dev.yml up -d
#   export MLFLOW_TRACKING_URI=http://localhost:5000
#
# The mlflow service installs from pip for exact version pinning; swap the
# build for your organization's base image if you have one.
services:
  mlflow-db:
    image: postgres:16
    environment:
      POSTGRES_USER: mlflow
      POSTGRES_PASSWORD: mlflow-dev-only
      POSTGRES_DB: mlflow
    volumes:
      - mlflow-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mlflow -d mlflow"]
      interval: 5s
      timeout: 3s
      retries: 10

  mlflow:
    image: python:3.12-slim
    command: >
      bash -c "pip install --quiet mlflow==3.15.1 psycopg2-binary &&
      mlflow server
      --backend-store-uri postgresql+psycopg2://mlflow:mlflow-dev-only@mlflow-db/mlflow
      --artifacts-destination /mlartifacts
      --host 0.0.0.0 --port 5000"
    environment:
      MLFLOW_DISABLE_TELEMETRY: "true"
    ports:
      - "5000:5000"
    volumes:
      - mlflow-artifacts:/mlartifacts
    depends_on:
      mlflow-db:
        condition: service_healthy

volumes:
  mlflow-db-data:
  mlflow-artifacts:
YAML

echo "Wrote: $COMPOSE_FILE"
echo ""
echo "Next steps (run these yourself — this script does not start services):"
echo "  docker compose -f docker-compose.mlflow-dev.yml up -d"
echo "  export MLFLOW_TRACKING_URI=http://localhost:5000"
echo "Then set dev_tracking_uri in this skill's config.json to http://localhost:5000"
