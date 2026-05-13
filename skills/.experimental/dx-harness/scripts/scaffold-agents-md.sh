#!/usr/bin/env bash
# scaffold-agents-md.sh — render AGENTS.md into a scratch dir
# Part of: dx-harness
#
# Generates an AGENTS.md from fingerprint facts. Every path/command in the
# output is one that was detected — no hallucinated references.
#
# Usage:
#   bash scaffold-agents-md.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq
[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP="$1"
[[ -f "$FP" ]] || die "Fingerprint file not found: $FP"

TASK_RUNNER=$(jq -r '.task_runner' "$FP")
BOOTSTRAP=$(jq -r '.bootstrap_command // ""' "$FP")
TEST_RUNNER=$(jq -r '.test_runner // ""' "$FP")
HAS_DB=$(jq -r '.has_database' "$FP")
LANGS=$(jq -r '.languages | join(", ")' "$FP")

# Pick the canonical command for each action, given the runner
case "$TASK_RUNNER" in
  just)         BOOTSTRAP_CMD="${BOOTSTRAP:-just bootstrap}"; DEV_CMD="just dev"; TEST_CMD="just test"; WATCH_CMD="just test-watch"; RESET_CMD="just reset"; SEED_CMD="just seed" ;;
  make)         BOOTSTRAP_CMD="${BOOTSTRAP:-make bootstrap}"; DEV_CMD="make dev"; TEST_CMD="make test"; WATCH_CMD="make test-watch"; RESET_CMD="make reset"; SEED_CMD="make seed" ;;
  npm-scripts)  BOOTSTRAP_CMD="${BOOTSTRAP:-./bootstrap.sh}"; DEV_CMD="npm run dev"; TEST_CMD="npm test"; WATCH_CMD="npm run test:watch"; RESET_CMD="./reset.sh"; SEED_CMD="./seed.sh" ;;
  *)            BOOTSTRAP_CMD="${BOOTSTRAP:-./bootstrap.sh}"; DEV_CMD="(start your server)"; TEST_CMD="${TEST_RUNNER:-(no test command detected)}"; WATCH_CMD="(no watcher detected)"; RESET_CMD="./reset.sh"; SEED_CMD="./seed.sh" ;;
esac

DB_SECTION=""
if [[ "$HAS_DB" == "true" ]]; then
  DB_SECTION=$(cat <<'EOM'

## Test User (seeded by `seed.sh`)

- Email: `dev@local.test`
- Password: `password`

This user is created by `seed.sh` as part of bootstrap. After running `reset`, the user is re-seeded automatically — do not register manually.
EOM
)
fi

OUT_DIR=$(scratch_dir "agents-md")
TMPL="${DX_SKILL_DIR}/assets/templates/AGENTS.md.tmpl"
[[ -f "$TMPL" ]] || die "Template missing: $TMPL"

render_template "$TMPL" "${OUT_DIR}/AGENTS.md" \
  "BOOTSTRAP_CMD=${BOOTSTRAP_CMD}" \
  "DEV_CMD=${DEV_CMD}" \
  "TEST_CMD=${TEST_CMD}" \
  "WATCH_CMD=${WATCH_CMD}" \
  "RESET_CMD=${RESET_CMD}" \
  "SEED_CMD=${SEED_CMD}" \
  "LANGUAGES=${LANGS:-(unknown)}" \
  "TASK_RUNNER=${TASK_RUNNER}" \
  "DB_SECTION=${DB_SECTION}"

log "Wrote AGENTS.md to ${OUT_DIR}/AGENTS.md"
printf '%s\n' "$OUT_DIR"
