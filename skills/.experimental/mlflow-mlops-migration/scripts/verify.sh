#!/usr/bin/env bash
# verify.sh — Assert the MLflow 3 setup actually works, phase by phase
# Part of: mlflow-mlops-migration
#
# Reads config.json and asserts on STATE, not on scripts having run:
#   - tracking server reachable (/health) AND answers an authenticated API call
#     (/health alone is exempt from auth and host validation, so it passes
#     against servers that reject every real client)
#   - experiment exists
#   - registered model exists and its @champion (or given) alias resolves
#   - served model answers /ping and /version (when serving_url configured)
#
# If the server runs basic-auth, export MLFLOW_TRACKING_USERNAME and
# MLFLOW_TRACKING_PASSWORD before running — they pass through to the client.
#
# Usage: verify.sh [env] [alias]
#   env   = dev | staging | prod   (default: dev)
#   alias = alias to resolve       (default: champion)
# Exit:  0 = all assertions passed, 1 = at least one failed or prerequisites missing

set -euo pipefail

ENVIRONMENT="${1:-dev}"
ALIAS="${2:-champion}"
CONFIG_FILE="$(dirname "$0")/../config.json"

case "$ENVIRONMENT" in
  dev|staging|prod) ;;
  *)
    echo "Unknown environment '$ENVIRONMENT' — expected dev, staging, or prod." >&2
    exit 1
    ;;
esac

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required (used to read config.json). Install it and re-run." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for the MLflow client assertions. Install it and re-run." >&2
  exit 1
fi
if ! python3 -c "import mlflow" >/dev/null 2>&1; then
  echo "The 'mlflow' package is not importable by python3." >&2
  echo "Activate the project environment (pip install mlflow==3.15.1) and re-run." >&2
  exit 1
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "config.json not found at $CONFIG_FILE" >&2
  exit 1
fi

TRACKING_URI="$(jq -r --arg k "${ENVIRONMENT}_tracking_uri" '.[$k] // ""' "$CONFIG_FILE")"
NAMESPACE="$(jq -r '.registry_namespace // ""' "$CONFIG_FILE")"
MODEL_NAME="$(jq -r '.model_name // ""' "$CONFIG_FILE")"
EXPERIMENT="$(jq -r '.experiment_name // ""' "$CONFIG_FILE")"
SERVING_URL="$(jq -r '.serving_url // ""' "$CONFIG_FILE")"

if [[ -z "$TRACKING_URI" ]]; then
  echo "Config incomplete: ${ENVIRONMENT}_tracking_uri is empty in config.json." >&2
  echo "Fill it (see _setup_instructions) and re-run." >&2
  exit 1
fi

REGISTERED_MODEL="${ENVIRONMENT}.${NAMESPACE}.${MODEL_NAME}"
export MLFLOW_TRACKING_URI="$TRACKING_URI"
export V_EXPERIMENT="$EXPERIMENT" V_MODEL="$REGISTERED_MODEL" V_ALIAS="$ALIAS"

PASS=0
FAIL=0
ERR_FILE="$(mktemp)"
trap 'rm -f "$ERR_FILE"' EXIT

assert_ok() {
  local label="$1"; shift
  if "$@" >/dev/null 2>"$ERR_FILE"; then
    echo "  PASS: $label"
    ((PASS+=1))
  else
    echo "  FAIL: $label"
    { grep -v '^[[:space:]]' "$ERR_FILE" || true; } | tail -1 | sed 's/^/        cause: /'
    ((FAIL+=1))
  fi
}

echo "Verifying environment '$ENVIRONMENT' against $TRACKING_URI"
echo ""

# --- Tracking server ---
if ! curl -fsS --max-time 10 "${TRACKING_URI%/}/health" >/dev/null 2>&1; then
  echo "  FAIL: tracking server answers /health" >&2
  echo "        Server unreachable at $TRACKING_URI — start it (phase 2) before verifying." >&2
  exit 1
fi
echo "  PASS: tracking server answers /health"
((PASS+=1))

assert_ok "authenticated API call succeeds (search_experiments)" \
  python3 -c "
from mlflow import MlflowClient
MlflowClient().search_experiments(max_results=1)"
if [[ $FAIL -gt 0 ]]; then
  echo "        Hints: with basic-auth, export MLFLOW_TRACKING_USERNAME/MLFLOW_TRACKING_PASSWORD;"
  echo "        a 403 'Invalid Host header' means the server needs --allowed-hosts (see references/environments.md)."
fi

# --- Experiment + registry state (via the MLflow client) ---
if [[ -n "$EXPERIMENT" ]]; then
  assert_ok "experiment '$EXPERIMENT' exists" \
    python3 -c "
import mlflow, os, sys
sys.exit(0 if mlflow.get_experiment_by_name(os.environ['V_EXPERIMENT']) else 1)"
else
  echo "  SKIP: experiment check (experiment_name empty in config.json)"
fi

if [[ -n "$NAMESPACE" && -n "$MODEL_NAME" ]]; then
  assert_ok "registered model '$REGISTERED_MODEL' exists" \
    python3 -c "
import os
from mlflow import MlflowClient
MlflowClient().get_registered_model(os.environ['V_MODEL'])"

  assert_ok "alias '@$ALIAS' resolves on '$REGISTERED_MODEL'" \
    python3 -c "
import os
from mlflow import MlflowClient
v = MlflowClient().get_model_version_by_alias(os.environ['V_MODEL'], os.environ['V_ALIAS'])
print(v.version)"
else
  echo "  SKIP: registry checks (registry_namespace or model_name empty in config.json)"
fi

# --- Serving (optional) ---
if [[ -n "$SERVING_URL" ]]; then
  assert_ok "scoring server answers /ping" \
    curl -fsS --max-time 10 "${SERVING_URL%/}/ping"
  assert_ok "scoring server reports /version" \
    curl -fsS --max-time 10 "${SERVING_URL%/}/version"
  echo "  NOTE: run a real /invocations smoke test with a domain payload —"
  echo "        see references/serving.md for the payload contract."
else
  echo "  SKIP: serving checks (serving_url empty in config.json)"
fi

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] || exit 1
