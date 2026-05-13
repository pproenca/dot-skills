#!/usr/bin/env bash
# scaffold-reset.sh — render reset.sh into a scratch dir
# Part of: dx-harness
#
# Generates a reset script that:
#   - Stops services (docker compose down -v if present)
#   - Wipes ephemeral data (node_modules only if --hard, build artifacts always)
#   - Re-runs bootstrap (which re-runs seed)
#
# Usage:
#   bash scaffold-reset.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq
[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP="$1"
[[ -f "$FP" ]] || die "Fingerprint file not found: $FP"

HAS_DB=$(jq -r '.has_database' "$FP")
LANGS=$(jq -r '.languages | join(",")' "$FP")

DOWN_SERVICES=""
if [[ "$HAS_DB" == "true" ]]; then
  DOWN_SERVICES="if [[ -f docker-compose.yml || -f compose.yaml || -f compose.yml ]]; then docker compose down -v; fi"
fi

CLEAN_ARTIFACTS=""
[[ ",${LANGS}," == *",javascript,"* || ",${LANGS}," == *",typescript,"* ]] && \
  CLEAN_ARTIFACTS="${CLEAN_ARTIFACTS}rm -rf .next dist build .turbo 2>/dev/null || true"$'\n'
[[ ",${LANGS}," == *",rust,"* ]] && \
  CLEAN_ARTIFACTS="${CLEAN_ARTIFACTS}rm -rf target 2>/dev/null || true"$'\n'
[[ ",${LANGS}," == *",python,"* ]] && \
  CLEAN_ARTIFACTS="${CLEAN_ARTIFACTS}find . -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true"$'\n'

OUT_DIR=$(scratch_dir "reset")
TMPL="${DX_SKILL_DIR}/assets/templates/reset.sh.tmpl"
[[ -f "$TMPL" ]] || die "Template missing: $TMPL"

render_template "$TMPL" "${OUT_DIR}/reset.sh" \
  "DOWN_SERVICES=${DOWN_SERVICES}" \
  "CLEAN_ARTIFACTS=${CLEAN_ARTIFACTS}"

chmod +x "${OUT_DIR}/reset.sh"
log "Wrote reset to ${OUT_DIR}/reset.sh"
printf '%s\n' "$OUT_DIR"
