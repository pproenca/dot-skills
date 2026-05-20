#!/usr/bin/env bash
# 04-validate-findings.sh — prove the transform is safe before applying it at scale.
# Part of: codemod-react-pipeline  (outer loop, step 4 — the validation gate)
#
# Applies the codemod to a clean working tree, runs the configured gates against the result,
# then reverts. Nothing is committed. A failure here means: do NOT proceed to step 05.
#
# Gates (toggle in config.json .gates):
#   idempotency  — applying twice yields no further change
#   typecheck    — config.typecheck_cmd succeeds
#   lint         — config.lint_cmd succeeds on affected files
#   format       — config.format_cmd succeeds on affected files
#   tests        — config.test_cmd succeeds (affected files appended where supported)
#
# Usage: bash 04-validate-findings.sh <name>
# Exit:  0 = all enabled gates pass, 1 = a gate failed / error.

set -uo pipefail   # not -e: run all gates, tally failures, always revert
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

NAME="${1:-}"
[[ -n "$NAME" ]] || { echo "Usage: $0 <name>" >&2; exit 1; }
need_cmd git; need_cmd jq
require_codemod "$NAME"

ROOT="$(target_root)"
STATE="$(state_dir_for "$NAME")"
STATE_BASE="$(config_get '.state_dir' '.codemod-pipeline')"
require_clean_git

PASS=0; FAIL=0; SKIP=0
gate_pass() { echo "${_C_GRN}  PASS${_C_RESET} $*" >&2; PASS=$((PASS+1)); }
gate_fail() { echo "${_C_RED}  FAIL${_C_RESET} $*" >&2; FAIL=$((FAIL+1)); }
gate_skip() { echo "${_C_DIM}  skip${_C_RESET} $*" >&2; SKIP=$((SKIP+1)); }

# Always restore the working tree, even on error. Exclude the state dir so the dry-run sentinel
# and gate logs survive the clean (robust even if the user hasn't .gitignored it).
restore() {
  git -C "$ROOT" checkout -- . 2>/dev/null || true
  git -C "$ROOT" clean -fdq -e "$STATE_BASE" -- . 2>/dev/null || true
}
trap restore EXIT

log_step "Applying '$NAME' to a clean tree for validation"
if ! codemod_apply "$NAME" "$ROOT" >/dev/null 2>&1; then
  die "Codemod failed to run. Fix it in the inner loop (02) before validating."
fi

mapfile -t AFFECTED < <(affected_files)
N=${#AFFECTED[@]}
if [[ "$N" -eq 0 ]]; then
  die "Transform produced no changes on a clean tree. Nothing to validate — revisit step 02/03."
fi
log_ok "$N file(s) changed; running gates"
echo "" >&2

# --- Gate: idempotency -----------------------------------------------------
if gate_enabled idempotency; then
  first="$(git -C "$ROOT" diff | git hash-object --stdin 2>/dev/null || echo first)"
  codemod_apply "$NAME" "$ROOT" >/dev/null 2>&1 || true
  second="$(git -C "$ROOT" diff | git hash-object --stdin 2>/dev/null || echo second)"
  if [[ "$first" == "$second" ]]; then
    gate_pass "idempotency (second application changed nothing)"
  else
    gate_fail "idempotency — applying twice keeps changing files. Add a guard so matched code is skipped once transformed (see codemod rule 'pattern-ensure-idempotency')."
  fi
else
  gate_skip "idempotency (disabled in config)"
fi

# Build a NUL-safe affected-file list for the file-scoped gates.
printf '%s\0' "${AFFECTED[@]}" > "$STATE/affected.0"

# run_gate <label> <enabled-name> <cmd-config-path> <append-files:yes|no>
run_gate() {
  local label="$1" name="$2" cfgpath="$3" append="$4" cmd
  if ! gate_enabled "$name"; then gate_skip "$label (disabled in config)"; return; fi
  cmd="$(config_get "$cfgpath" '')"
  if [[ -z "$cmd" ]]; then gate_skip "$label (no command configured)"; return; fi
  log_info "$label: $cmd"
  local rc=0
  if [[ "$append" == "yes" ]]; then
    # Pass affected files as arguments (NUL-delimited via stdin redirect — portable to BSD/macOS,
    # unlike GNU-only `xargs -a`).
    ( cd "$ROOT" && xargs -0 $cmd < "$STATE/affected.0" ) >"$STATE/$name.log" 2>&1 || rc=$?
  else
    ( cd "$ROOT" && $cmd ) >"$STATE/$name.log" 2>&1 || rc=$?
  fi
  if [[ $rc -eq 0 ]]; then gate_pass "$label"; else
    gate_fail "$label (exit $rc) — see ${STATE#"$ROOT"/}/$name.log"
  fi
}

run_gate "typecheck" typecheck ".typecheck_cmd" no
run_gate "lint"      lint      ".lint_cmd"      yes
run_gate "format"    format    ".format_cmd"    yes
run_gate "tests"     tests     ".test_cmd"      yes

echo "" >&2
log_step "Reverting validation changes"
# (trap restore runs on exit)

echo "" >&2
echo "Gate results: $PASS passed, $FAIL failed, $SKIP skipped" >&2
if [[ $FAIL -ne 0 ]]; then
  echo "${_C_RED}Do not proceed to step 05 until these pass.${_C_RESET}" >&2
  exit 1
fi
log_ok "All enabled gates passed. Safe to apply at scale:"
echo "  bash $SCRIPT_DIR/05-run-batched.sh $NAME" >&2
