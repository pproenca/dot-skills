#!/usr/bin/env bash
# verify.sh — Run typecheck + lint against the codemodded tree, revert on failure.
# Part of: nuqs-codemod-runner

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_ROOT/config.json"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$SKILL_ROOT}"
LAST_RUN_FILE="$DATA_DIR/last-run.json"

if [[ ! -f "$LAST_RUN_FILE" ]]; then
  echo "Error: $LAST_RUN_FILE not found. Run 'scripts/apply.sh' first." >&2
  exit 1
fi

REPO_ROOT=$(jq -r '.repoRoot' "$LAST_RUN_FILE")
TYPECHECK=$(jq -r '.typecheck_command' "$CONFIG_FILE")
LINT=$(jq -r '.lint_command' "$CONFIG_FILE")

cd "$REPO_ROOT"

PASS=0
FAIL=0
LOG_DIR="$DATA_DIR/verify-logs"
mkdir -p "$LOG_DIR"
TS=$(date -u +%Y%m%dT%H%M%SZ)

run_check() {
  local label="$1" cmd="$2" log="$LOG_DIR/${label}-${TS}.log"
  echo "→ $label: $cmd"
  if eval "$cmd" >"$log" 2>&1; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label (see $log)"
    FAIL=$((FAIL + 1))
  fi
}

run_check "typecheck" "$TYPECHECK"
run_check "lint"      "$LINT"

echo
echo "Results: $PASS passed, $FAIL failed"

if (( FAIL > 0 )); then
  echo
  echo "Verification failed — reverting touched files via 'git restore'." >&2

  mapfile -t TOUCHED < <(jq -r '.touchedFiles[]' "$LAST_RUN_FILE")
  if [[ ${#TOUCHED[@]} -gt 0 ]]; then
    git restore -- "${TOUCHED[@]}"
    echo "Reverted ${#TOUCHED[@]} file(s)." >&2
  fi

  echo "Logs preserved in $LOG_DIR." >&2
  exit 1
fi

echo "All checks passed. Review the diff and commit when ready."
