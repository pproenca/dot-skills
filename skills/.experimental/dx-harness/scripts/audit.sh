#!/usr/bin/env bash
# audit.sh — run DX checks against a repo fingerprint
# Part of: dx-harness
#
# Reads a fingerprint JSON, runs each check from references/audit-checklist.md,
# emits findings JSON to stdout. Findings have shape:
#   { id, category, severity, title, evidence,
#     fix_recipe, frequency_score, pain_score, fix_cost_score }
#
# Usage:
#   bash audit.sh <fingerprint-json>
#   bash audit.sh /tmp/fingerprint.json > /tmp/audit.json
#
# Env knobs:
#   DX_HARNESS_HISTORY_DAYS    (default 90)
#   DX_HARNESS_HISTORY_COMMITS (default 200)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq

[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP_FILE="$1"
[[ -f "$FP_FILE" ]] || die "Fingerprint file not found: $FP_FILE  (run scripts/discover.sh first)"

ROOT=$(jq -r '.repo_root' "$FP_FILE")
[[ -d "$ROOT" ]] || die "Fingerprint repo_root is not a directory: $ROOT"

TTFC_TARGET=$(config_get "ttfc_target_seconds" 60)
HISTORY_DAYS="${DX_HARNESS_HISTORY_DAYS:-90}"
HISTORY_COMMITS="${DX_HARNESS_HISTORY_COMMITS:-200}"

# --- skip list from config ---
SKIP_RAW=$(jq -r '.skip_checks // [] | .[]?' "$DX_CONFIG_FILE" 2>/dev/null || true)
should_skip() {
  local id="$1"
  while read -r s; do
    [[ -n "$s" && "$s" == "$id" ]] && return 0
  done <<< "$SKIP_RAW"
  return 1
}

# Findings are accumulated as JSON lines, then merged at the end.
FINDINGS_FILE=$(mktemp -t dx-audit-XXXXXX.jsonl)
trap 'rm -f "$FINDINGS_FILE"' EXIT

emit() {
  # Usage: emit ID CATEGORY SEVERITY TITLE EVIDENCE FIX_RECIPE FREQ PAIN COST
  jq -nc \
    --arg id "$1" --arg category "$2" --arg severity "$3" \
    --arg title "$4" --arg evidence "$5" --arg fix_recipe "$6" \
    --argjson freq "$7" --argjson pain "$8" --argjson cost "$9" \
    '{id:$id, category:$category, severity:$severity, title:$title,
      evidence:$evidence, fix_recipe:$fix_recipe,
      frequency_score:$freq, pain_score:$pain, fix_cost_score:$cost}' \
    >> "$FINDINGS_FILE"
}

# ---------------- Checks ----------------

# bootstrap-exists
if ! should_skip bootstrap-exists; then
  BOOTSTRAP=$(jq -r '.bootstrap_command' "$FP_FILE")
  if [[ -z "$BOOTSTRAP" || "$BOOTSTRAP" == "null" ]]; then
    emit bootstrap-exists harness P1 \
      "No one-command bootstrap detected" \
      "Did not find bootstrap.sh, just bootstrap, make bootstrap, or npm run bootstrap" \
      scaffold-bootstrap 10 9 3
  fi
fi

# reset-exists
if ! should_skip reset-exists; then
  HAS_RESET=$(jq -r '.existing_scripts // [] | map(select(. == "reset.sh" or . == "scripts/reset.sh")) | length' "$FP_FILE")
  HAS_DB=$(jq -r '.has_database' "$FP_FILE")
  HAS_RUNNER_RESET="false"
  if [[ -f "${ROOT}/Justfile" ]] && grep -qE '^reset:' "${ROOT}/Justfile" 2>/dev/null; then HAS_RUNNER_RESET="true"; fi
  if [[ -f "${ROOT}/Makefile" ]] && grep -qE '^reset:'  "${ROOT}/Makefile"  2>/dev/null; then HAS_RUNNER_RESET="true"; fi
  if [[ "$HAS_RESET" == "0" && "$HAS_RUNNER_RESET" == "false" ]]; then
    if [[ "$HAS_DB" == "true" ]]; then
      emit reset-exists harness P1 \
        "No reset command — repo has a database but no clean-slate workflow" \
        "Database detected but no reset.sh / just reset / make reset" \
        scaffold-reset 7 8 3
    else
      emit reset-exists harness P2 \
        "No reset command — minor, repo has no database" \
        "No reset.sh / just reset / make reset (no database detected)" \
        scaffold-reset 4 4 3
    fi
  fi
fi

# seed-exists
if ! should_skip seed-exists; then
  HAS_DB=$(jq -r '.has_database' "$FP_FILE")
  if [[ "$HAS_DB" == "true" ]]; then
    HAS_SEED=$(jq -r '.existing_scripts // [] | map(select(. == "seed.sh" or . == "scripts/seed.sh")) | length' "$FP_FILE")
    HAS_RUNNER_SEED="false"
    if [[ -f "${ROOT}/Justfile" ]] && grep -qE '^seed:' "${ROOT}/Justfile" 2>/dev/null; then HAS_RUNNER_SEED="true"; fi
    if [[ -f "${ROOT}/Makefile" ]] && grep -qE '^seed:'  "${ROOT}/Makefile"  2>/dev/null; then HAS_RUNNER_SEED="true"; fi
    if [[ -f "${ROOT}/package.json" ]] && jq -e '.scripts.seed // .scripts["db:seed"] // empty' "${ROOT}/package.json" >/dev/null 2>&1; then
      HAS_RUNNER_SEED="true"
    fi
    if [[ "$HAS_SEED" == "0" && "$HAS_RUNNER_SEED" == "false" ]]; then
      emit seed-exists harness P1 \
        "No idempotent seed — devs must register/configure manually after every reset" \
        "Database detected, but no seed.sh / just seed / package.json seed script" \
        scaffold-seed 9 9 3
    fi
  fi
fi

# test-command
if ! should_skip test-command; then
  TEST_RUNNER=$(jq -r '.test_runner' "$FP_FILE")
  if [[ -z "$TEST_RUNNER" || "$TEST_RUNNER" == "null" ]]; then
    emit test-command harness P1 \
      "No test command detected" \
      "Neither package.json test script, Justfile test target, pytest config, cargo, nor go test detected" \
      manual 10 10 8
  fi
fi

# agents-md
if ! should_skip agents-md; then
  HAS_AGENTS=$(jq -r '.agents_md_present' "$FP_FILE")
  if [[ "$HAS_AGENTS" != "true" ]]; then
    emit agents-md harness P1 \
      "No AGENTS.md / CLAUDE.md — agents can't discover the dev loop" \
      "Did not find AGENTS.md, CLAUDE.md, or .cursorrules" \
      scaffold-agents-md 10 6 2
  fi
fi

# ci-status
if ! should_skip ci-status; then
  CI=$(jq -r '.ci_provider' "$FP_FILE")
  if [[ "$CI" == "none" || -z "$CI" ]]; then
    emit ci-status harness P2 \
      "No CI workflow detected" \
      "No .github/workflows, .circleci, .gitlab-ci, or azure-pipelines" \
      manual 6 6 7
  fi
fi

# dependency-pin-drift
if ! should_skip dependency-pin-drift; then
  LOCK=$(jq -r '.lockfile_status' "$FP_FILE")
  case "$LOCK" in
    untracked)
      emit dependency-pin-drift harness P2 \
        "Lockfile exists but is not committed" \
        "Lockfile present in working tree but git does not track it" \
        manual 5 7 1
      ;;
    no-lockfile)
      HAS_PKG="false"
      [[ -f "${ROOT}/package.json" ]] && HAS_PKG="true"
      [[ -f "${ROOT}/Cargo.toml"  ]] && HAS_PKG="true"
      if [[ "$HAS_PKG" == "true" ]]; then
        emit dependency-pin-drift harness P2 \
          "No lockfile present" \
          "Package manifest exists but no corresponding lockfile" \
          manual 5 7 2
      fi
      ;;
  esac
fi

# repeated-manual-steps (history scan)
if ! should_skip repeated-manual-steps; then
  SINCE_ARG=()
  if [[ -n "$HISTORY_DAYS" ]]; then
    SINCE_ARG=(--since="${HISTORY_DAYS} days ago")
  fi
  LOG_OUT=$( ( cd "$ROOT" && git log --all --oneline -i "${SINCE_ARG[@]}" -n "$HISTORY_COMMITS" 2>/dev/null ) || true)

  patterns=(
    "again|every time|always need:repeated-toil:scaffold-bootstrap:8:7:3"
    "manual(ly)?|by hand:manual-step:scaffold-bootstrap:7:7:3"
    "re-?seed|reset.{0,5}db|wipe.{0,5}db|drop.{0,5}db:db-recovery:scaffold-reset:9:8:3"
    "register again|re-?login|re-?register|test user|create.{0,10}account|signup:re-register:scaffold-seed:10:9:2"
    "wip.{0,5}setup|fix.{0,5}bootstrap|getting.{0,5}started:bootstrap-churn:scaffold-bootstrap:7:8:3"
    "flaky|intermittent|sometimes fails:flaky-test:manual:6:8:8"
  )

  for entry in "${patterns[@]}"; do
    IFS=':' read -r regex category recipe freq pain cost <<< "$entry"
    COUNT=$(printf '%s\n' "$LOG_OUT" | grep -Ec -i "$regex" || true)
    if [[ "$COUNT" -gt 0 ]]; then
      sev=P2
      [[ "$COUNT" -ge 5 ]] && sev=P1
      emit "attrition-${category}" history "$sev" \
        "Git history shows ${COUNT} commits matching pattern: ${category}" \
        "Pattern '${regex}' matched ${COUNT}x in last ${HISTORY_COMMITS} commits / ${HISTORY_DAYS}d" \
        "$recipe" "$freq" "$pain" "$cost"
    fi
  done
fi

# ---------------- Emit findings array ----------------
jq -n \
  --slurpfile findings "$FINDINGS_FILE" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson ttfc_target "$TTFC_TARGET" \
  --slurpfile fingerprint "$FP_FILE" \
  '{
    schema_version: 1,
    generated_at: $generated_at,
    ttfc_target_seconds: $ttfc_target,
    fingerprint_hash: ($fingerprint[0].repo_hash // null),
    findings: ($findings | flatten),
    total_findings: ($findings | flatten | length)
  }'
