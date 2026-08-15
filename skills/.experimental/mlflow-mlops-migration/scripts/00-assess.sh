#!/usr/bin/env bash
# 00-assess.sh — Read-only audit of an ML codebase's MLflow readiness
# Part of: mlflow-mlops-migration
#
# Greps the target codebase for ML frameworks, existing MLflow usage, MLflow 2-era
# idioms that MLflow 3 deprecates/removes, side-loaded model artifacts, and the
# environment-management story. Writes a markdown report; changes nothing.
#
# Usage: 00-assess.sh <codebase-dir> [report-out.md]
# Exit:  0 = report written, 1 = bad arguments

set -euo pipefail

if [[ $# -lt 1 || ! -d "${1:-}" ]]; then
  echo "Usage: $0 <codebase-dir> [report-out.md]" >&2
  echo "  <codebase-dir> must be an existing directory." >&2
  exit 1
fi

CODEBASE="$(cd "$1" && pwd)"
REPORT="${2:-mlflow-assessment.md}"

REPORT_DIR="$(dirname "$REPORT")"
if [[ ! -d "$REPORT_DIR" ]]; then
  echo "Output directory does not exist: $REPORT_DIR" >&2
  echo "Create it or pass a different report path." >&2
  exit 1
fi
# Overwrite only our own previous report — never an unrelated file.
if [[ -e "$REPORT" ]] && ! head -1 "$REPORT" | grep -q '^# MLflow Readiness Assessment'; then
  echo "Refusing to overwrite $REPORT — it is not a previous assessment report." >&2
  echo "Pass a different output path." >&2
  exit 1
fi

# grep wrapper: count + up to 5 sample locations, never failing the script on no-match
scan() {
  local pattern="$1"
  grep -rnE --include='*.py' --exclude-dir='.git' --exclude-dir='.venv' \
    --exclude-dir='venv' --exclude-dir='node_modules' --exclude-dir='__pycache__' \
    -e "$pattern" "$CODEBASE" 2>/dev/null || true
}

section() {
  local title="$1" pattern="$2"
  local hits count
  hits="$(scan "$pattern")"
  count="$(printf '%s' "$hits" | grep -c . || true)"
  {
    echo "### $title"
    echo ""
    echo "Pattern: \`$pattern\` — **$count** hit(s)"
    if [[ "$count" -gt 0 ]]; then
      echo ""
      echo '```text'
      printf '%s\n' "$hits" | head -5 | while IFS= read -r line; do
        printf '%s\n' "${line#"$CODEBASE"/}"
      done
      [[ "$count" -gt 5 ]] && echo "... ($((count - 5)) more)"
      echo '```'
    fi
    echo ""
  } >> "$REPORT"
}

file_inventory() {
  local title="$1"; shift
  {
    echo "### $title"
    echo ""
    local found=0 f
    for f in "$@"; do
      if compgen -G "$CODEBASE/$f" > /dev/null 2>&1; then
        echo "- \`$f\` present"
        found=1
      fi
    done
    [[ "$found" -eq 0 ]] && echo "- none found"
    echo ""
  } >> "$REPORT"
}

: > "$REPORT"
{
  echo "# MLflow Readiness Assessment"
  echo ""
  echo "- Codebase: \`$CODEBASE\`"
  echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ) by 00-assess.sh (read-only)"
  echo ""
  echo "## 1. ML frameworks in use"
  echo ""
} >> "$REPORT"

section "scikit-learn"   'from sklearn|import sklearn'
section "PyTorch"        'import torch|from torch'
section "TensorFlow/Keras" 'import tensorflow|from tensorflow|import keras|from keras'
section "XGBoost"        'import xgboost|from xgboost'
section "LightGBM"       'import lightgbm|from lightgbm'

echo "## 2. Existing MLflow usage" >> "$REPORT"
echo "" >> "$REPORT"
section "Any MLflow import" 'import mlflow|from mlflow'
section "Model logging calls" 'log_model\('
section "Run management" 'start_run\(|set_experiment\('
section "Registry usage" 'register_model\(|MlflowClient\('

echo "## 3. MLflow 2-era idioms (each maps to an mlflow-3 rule)" >> "$REPORT"
echo "" >> "$REPORT"
section "artifact_path= in log_model (log-name-not-artifact-path)" 'log_model\([^)]*artifact_path='
section "Registry stages (reg-aliases-not-stages)" 'transition_model_version_stage|get_latest_versions'
section "Stage-based model URIs (reg-resolve-by-alias-not-latest-versions)" 'models:/[A-Za-z0-9_.-]+/(Production|Staging|Archived|None)'
section "runs:/ URIs (log-register-at-log-time)" 'runs:/'
section "Top-level mlflow.evaluate (eval-models-evaluate-split)" 'mlflow\.evaluate\('
section "baseline_model / custom_metrics (eval-gate-with-validate-evaluation-results)" 'baseline_model=|custom_metrics='
section "validate_serving_input (serve-predict-before-deploy)" 'validate_serving_input'
section "MLflow Recipes (removed in 3.0)" 'mlflow\.recipes|from mlflow import recipes'

echo "## 4. Model shipping outside MLflow" >> "$REPORT"
echo "" >> "$REPORT"
section "Direct pickle/joblib artifact I/O" 'joblib\.(dump|load)\(|pickle\.(dump|load)\('
section "Hand-rolled serving apps" 'Flask\(__name__\)|FastAPI\('

echo "## 5. Environment management" >> "$REPORT"
echo "" >> "$REPORT"
file_inventory "Dependency files" \
  "requirements.txt" "pyproject.toml" "uv.lock" "poetry.lock" "Pipfile" \
  "environment.yml" "conda.yaml" "setup.py"
file_inventory "Container/deploy files" \
  "Dockerfile" "docker-compose.yml" "docker-compose.yaml" "Makefile" \
  ".github/workflows/*.yml" ".gitlab-ci.yml"
file_inventory "Legacy MLflow storage" "mlruns" "mlflow.db" "mlartifacts"

{
  echo "## 6. Next step"
  echo ""
  echo "Review each hit above with the developer, then proceed to phase 1"
  echo "(domain modelling — references/domain-modelling.md). Every 'MLflow 2-era"
  echo "idiom' hit names the sibling mlflow-3 rule that phase 3 will apply."
} >> "$REPORT"

echo "Assessment written to: $REPORT"
