#!/usr/bin/env bash
# track-attrition.sh — append audit to log, diff vs previous
# Part of: dx-harness
#
# Persists each audit run keyed by repo_hash. Reads the previous audit for the
# same repo and prints a short diff: new findings (regressions), missing findings
# (wins), score-of-scores trend.
#
# Storage: ${CLAUDE_PLUGIN_DATA}/dx-harness/audits.log (NDJSON, append-only)
#
# Usage:
#   bash track-attrition.sh <audit-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq

[[ $# -eq 1 ]] || die "Usage: $0 <audit-json>"
AUDIT_FILE="$1"
[[ -f "$AUDIT_FILE" ]] || die "Audit file not found: $AUDIT_FILE"

LOG_FILE=$(config_get "audit_log_path" "${DX_DATA_DIR}/audits.log")
# config_get already runs safe_expand; nothing more to do.
mkdir -p "$(dirname "$LOG_FILE")"

REPO_HASH=$(jq -r '.fingerprint_hash // ""' "$AUDIT_FILE")
[[ -n "$REPO_HASH" && "$REPO_HASH" != "null" ]] || die "Audit missing fingerprint_hash"

# --- find previous entry for this repo (last line where fingerprint_hash matches) ---
PREV=""
if [[ -f "$LOG_FILE" ]]; then
  PREV=$(grep -F "\"fingerprint_hash\":\"${REPO_HASH}\"" "$LOG_FILE" | tail -1 || true)
fi

# --- append current ---
COMPACT=$(jq -c '.' "$AUDIT_FILE")
printf '%s\n' "$COMPACT" >> "$LOG_FILE"

# --- print trend summary ---
CUR_TOTAL=$(jq -r '.total_findings // 0' "$AUDIT_FILE")
CUR_IDS=$(jq -r '.findings[]?.id' "$AUDIT_FILE" | sort -u)

if [[ -z "$PREV" ]]; then
  printf 'Trend: first audit for this repo (hash %s). %d findings recorded.\n' "$REPO_HASH" "$CUR_TOTAL"
  exit 0
fi

PREV_TOTAL=$(printf '%s' "$PREV" | jq -r '.total_findings // 0')
PREV_IDS=$(printf '%s' "$PREV" | jq -r '.findings[]?.id' | sort -u)

NEW_IDS=$(comm -23 <(printf '%s' "$CUR_IDS") <(printf '%s' "$PREV_IDS") || true)
RESOLVED_IDS=$(comm -13 <(printf '%s' "$CUR_IDS") <(printf '%s' "$PREV_IDS") || true)

DELTA=$((CUR_TOTAL - PREV_TOTAL))
SIGN="="
[[ $DELTA -gt 0 ]] && SIGN="+"
[[ $DELTA -lt 0 ]] && SIGN=""  # negative already prints with -

printf 'Trend: %d findings (%s%d vs previous audit).\n' "$CUR_TOTAL" "$SIGN" "$DELTA"

if [[ -n "$NEW_IDS" ]]; then
  printf '  Regressions (new findings):\n'
  printf '    - %s\n' $NEW_IDS
fi
if [[ -n "$RESOLVED_IDS" ]]; then
  printf '  Wins (resolved since last audit):\n'
  printf '    - %s\n' $RESOLVED_IDS
fi
