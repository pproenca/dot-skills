#!/usr/bin/env bash
# verify.sh — final assertions over a completed migration.
# Part of: codemod-react-pipeline  (outer loop, step 6 — sign-off)
#
# Run after 05-run-batched.sh. Asserts the end state is correct (not just "commands exited 0"):
#   - every planned batch is recorded complete
#   - the codemod is now a no-op (re-running it changes nothing → migration is complete + idempotent)
#   - the project type-checks
#   - no leftover migration markers (CODEMOD-TODO) remain
#
# Usage: bash verify.sh <name>
# Exit:  0 = all assertions pass, 1 = a failure.

set -uo pipefail   # run all assertions, tally
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

NAME="${1:-}"
[[ -n "$NAME" ]] || { echo "Usage: $0 <name>" >&2; exit 1; }
need_cmd git; need_cmd jq
require_codemod "$NAME"

ROOT="$(target_root)"
STATE="$(state_dir_for "$NAME")"

PASS=0; FAIL=0
assert_pass() { echo "${_C_GRN}  PASS${_C_RESET} $*" >&2; PASS=$((PASS+1)); }
assert_fail() { echo "${_C_RED}  FAIL${_C_RESET} $*" >&2; FAIL=$((FAIL+1)); }

log_step "Verifying migration '$NAME'"

# --- 1. All batches recorded complete --------------------------------------
PROGRESS="$STATE/progress.tsv"
if [[ -f "$PROGRESS" ]]; then
  if grep -q $'\tfail\t' "$PROGRESS"; then
    assert_fail "progress log contains failed batches — re-run 05-run-batched.sh to finish"
  else
    done_n=$(grep -c $'\tok\t' "$PROGRESS"); assert_pass "$done_n batch(es) recorded complete, none failed"
  fi
else
  assert_fail "no progress log at ${PROGRESS#"$ROOT"/} — has 05-run-batched.sh run?"
fi

# --- 2. Codemod is now a no-op (complete + idempotent) ---------------------
if [[ -n "$(git -C "$ROOT" status --porcelain)" ]]; then
  assert_fail "working tree is dirty — commit or inspect before verifying re-application"
else
  codemod_apply "$NAME" "$ROOT" >/dev/null 2>&1 || true
  if git -C "$ROOT" diff --quiet; then
    assert_pass "re-running the codemod produces no changes (migration complete + idempotent)"
  else
    leftover=$(git -C "$ROOT" diff --name-only | wc -l | tr -d ' ')
    assert_fail "re-running the codemod still changes $leftover file(s) — migration is incomplete"
  fi
  git -C "$ROOT" checkout -- . 2>/dev/null || true
fi

# --- 3. Project type-checks ------------------------------------------------
if gate_enabled typecheck; then
  TC="$(config_get '.typecheck_cmd' '')"
  if [[ -n "$TC" ]]; then
    if ( cd "$ROOT" && $TC ) >"$STATE/verify-typecheck.log" 2>&1; then
      assert_pass "typecheck passes"
    else
      assert_fail "typecheck failed — see ${STATE#"$ROOT"/}/verify-typecheck.log"
    fi
  fi
fi

# --- 4. No leftover migration markers --------------------------------------
mapfile -t MARKER_SPECS < <(_pathspecs)
[[ ${#MARKER_SPECS[@]} -gt 0 ]] || MARKER_SPECS=(':(glob)src/**/*.tsx')
markers=$(git -C "$ROOT" grep -lI 'CODEMOD-TODO' -- "${MARKER_SPECS[@]}" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$markers" -eq 0 ]]; then
  assert_pass "no CODEMOD-TODO markers left behind"
else
  assert_fail "$markers file(s) still contain CODEMOD-TODO — resolve before sign-off"
fi

echo "" >&2
echo "Verify results: $PASS passed, $FAIL failed" >&2
[[ $FAIL -eq 0 ]] || exit 1
log_ok "Migration '$NAME' verified."
