#!/usr/bin/env bash
# verify.sh — assert the harness actually works
# Part of: dx-harness
#
# Creates a fresh git worktree in $TMPDIR, runs the detected bootstrap command,
# times it, runs reset if present, runs the test command, asserts pass.
# Cleans up the worktree on exit.
#
# Output: PASS/FAIL report. Exit 0 if all pass, 1 if any FAIL.
#
# Usage:
#   bash verify.sh                   # detect everything from current repo
#   bash verify.sh <fingerprint-json> # use a pre-computed fingerprint

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq

TTFC_TARGET=$(config_get "ttfc_target_seconds" 60)

if [[ $# -ge 1 ]]; then
  FP="$1"
else
  FP=$(mktemp -t dx-fp-XXXXXX.json)
  bash "${SCRIPT_DIR}/discover.sh" > "$FP"
  trap 'rm -f "$FP"' EXIT
fi

BOOTSTRAP=$(jq -r '.bootstrap_command // ""' "$FP")
TASK_RUNNER=$(jq -r '.task_runner' "$FP")
TEST_RUNNER=$(jq -r '.test_runner' "$FP")
ROOT=$(jq -r '.repo_root' "$FP")

[[ -d "$ROOT" ]] || die "repo_root invalid: $ROOT"

# Pick test command from fingerprint
case "$TEST_RUNNER" in
  vitest)      TEST_CMD="npx vitest run" ;;
  jest)        TEST_CMD="npx jest" ;;
  pytest)      TEST_CMD="pytest" ;;
  cargo-test)  TEST_CMD="cargo test" ;;
  go-test)     TEST_CMD="go test ./..." ;;
  npm-test)    TEST_CMD="npm test" ;;
  "")          TEST_CMD="" ;;
  *)           TEST_CMD="$TEST_RUNNER" ;;
esac

WT=$(scratch_dir "verify-wt")
make_worktree "$WT" >/dev/null
register_worktree_cleanup "$WT"

PASS=0
FAIL=0
report=""

assert() {
  local label="$1" cond="$2" detail="${3:-}"
  if [[ "$cond" == "true" ]]; then
    report+="  PASS: ${label}"$'\n'
    [[ -n "$detail" ]] && report+="        ${detail}"$'\n'
    PASS=$((PASS + 1))
  else
    report+="  FAIL: ${label}"$'\n'
    [[ -n "$detail" ]] && report+="        ${detail}"$'\n'
    FAIL=$((FAIL + 1))
  fi
}

# --- 1. Bootstrap exists ---
if [[ -n "$BOOTSTRAP" ]]; then
  assert "bootstrap command exists" "true" "detected: ${BOOTSTRAP}"
else
  assert "bootstrap command exists" "false" "no bootstrap.sh / just bootstrap / make bootstrap"
fi

# --- 2. Bootstrap runs successfully in scratch worktree ---
BOOTSTRAP_MS=0
if [[ -n "$BOOTSTRAP" ]]; then
  log "Running bootstrap in scratch worktree: $WT"
  bootstrap_log=$(mktemp -t dx-bootstrap-log-XXXXXX)
  set +e
  start_ms=$(python3 -c 'import time;print(int(time.time()*1000))')
  ( cd "$WT" && eval "$BOOTSTRAP" ) > "$bootstrap_log" 2>&1
  rc=$?
  end_ms=$(python3 -c 'import time;print(int(time.time()*1000))')
  set -e
  BOOTSTRAP_MS=$((end_ms - start_ms))
  if [[ $rc -eq 0 ]]; then
    assert "bootstrap completes successfully" "true" "took ${BOOTSTRAP_MS}ms"
  else
    tail_excerpt=$(tail -n 5 "$bootstrap_log" | tr '\n' '|')
    assert "bootstrap completes successfully" "false" "exit=${rc}, tail: ${tail_excerpt}"
  fi
  rm -f "$bootstrap_log"
fi

# --- 3. TTFC under target ---
target_ms=$((TTFC_TARGET * 1000))
if [[ "$BOOTSTRAP_MS" -gt 0 && "$BOOTSTRAP_MS" -le "$target_ms" ]]; then
  assert "time-to-first-commit under target" "true" "${BOOTSTRAP_MS}ms <= ${target_ms}ms (target ${TTFC_TARGET}s)"
elif [[ "$BOOTSTRAP_MS" -gt 0 ]]; then
  assert "time-to-first-commit under target" "false" "${BOOTSTRAP_MS}ms > ${target_ms}ms (target ${TTFC_TARGET}s)"
fi

# --- 4. Reset roundtrip (if reset.sh exists) ---
# Asserts the harness's central promise: after reset, the env is ready again
# without manual steps (re-register, re-login, hand-edit DB).
if [[ -x "${WT}/reset.sh" ]]; then
  log "Running reset roundtrip in scratch worktree"
  reset_log=$(mktemp -t dx-reset-log-XXXXXX)
  set +e
  ( cd "$WT" && ./reset.sh ) > "$reset_log" 2>&1
  reset_rc=$?
  set -e
  if [[ $reset_rc -eq 0 ]]; then
    assert "reset.sh completes successfully (env re-prepared without manual steps)" "true" ""
  else
    tail_excerpt=$(tail -n 5 "$reset_log" | tr '\n' '|')
    assert "reset.sh completes successfully (env re-prepared without manual steps)" "false" "exit=${reset_rc}, tail: ${tail_excerpt}"
  fi
  rm -f "$reset_log"
fi

# --- 5. Test command exists and passes ---
if [[ -n "$TEST_CMD" ]]; then
  set +e
  test_log=$(mktemp -t dx-test-log-XXXXXX)
  ( cd "$WT" && eval "$TEST_CMD" ) > "$test_log" 2>&1
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    assert "tests pass" "true" "command: ${TEST_CMD}"
  else
    tail_excerpt=$(tail -n 5 "$test_log" | tr '\n' '|')
    assert "tests pass" "false" "exit=${rc}, command: ${TEST_CMD}, tail: ${tail_excerpt}"
  fi
  rm -f "$test_log"
else
  assert "test command exists" "false" "no test runner detected"
fi

# --- 6. AGENTS.md present ---
if [[ "$(jq -r '.agents_md_present' "$FP")" == "true" ]]; then
  assert "AGENTS.md present" "true" "path: $(jq -r '.agents_md_path' "$FP")"
else
  assert "AGENTS.md present" "false" "no AGENTS.md / CLAUDE.md found"
fi

# --- Summary ---
echo ""
echo "Verify report (worktree: $WT):"
echo "$report"
echo "Results: ${PASS} passed, ${FAIL} failed"

if [[ "$BOOTSTRAP_MS" -gt 0 ]]; then
  echo "TTFC (bootstrap wall-clock): ${BOOTSTRAP_MS}ms"
fi

[[ $FAIL -eq 0 ]] || exit 1
