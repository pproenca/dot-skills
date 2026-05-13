#!/usr/bin/env bash
# scaffold-bootstrap.sh — render bootstrap.sh into a scratch dir
# Part of: dx-harness
#
# Reads fingerprint, picks the right template variant, substitutes vars,
# writes to a fresh scratch dir, prints the scratch path on stdout.
# Never writes into the working tree directly.
#
# Usage:
#   bash scaffold-bootstrap.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq
[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP="$1"
[[ -f "$FP" ]] || die "Fingerprint file not found: $FP"

PKG_MGR=$(jq -r '.package_manager // ""' "$FP")
HAS_DB=$(jq -r '.has_database' "$FP")
DB_KIND=$(jq -r '.db_kind // ""' "$FP")
LANGS=$(jq -r '.languages | join(",")' "$FP")

# Choose install command for the detected package manager
case "$PKG_MGR" in
  pnpm) INSTALL_CMD="pnpm install --frozen-lockfile" ;;
  yarn) INSTALL_CMD="yarn install --frozen-lockfile" ;;
  bun)  INSTALL_CMD="bun install --frozen-lockfile" ;;
  npm)  INSTALL_CMD="npm ci || npm install" ;;
  "")   INSTALL_CMD="" ;;
  *)    INSTALL_CMD="$PKG_MGR install" ;;
esac

# Python install
PY_INSTALL=""
if [[ ",${LANGS}," == *",python,"* ]]; then
  if [[ -f "$(jq -r '.repo_root' "$FP")/uv.lock" ]]; then
    PY_INSTALL="uv sync"
  elif [[ -f "$(jq -r '.repo_root' "$FP")/poetry.lock" ]]; then
    PY_INSTALL="poetry install"
  else
    PY_INSTALL="python3 -m pip install -e ."
  fi
fi

# Rust install
RUST_BUILD=""
[[ ",${LANGS}," == *",rust,"* ]] && RUST_BUILD="cargo build --quiet"

# Go install
GO_INSTALL=""
[[ ",${LANGS}," == *",go,"* ]] && GO_INSTALL="go mod download"

# Database service start
DB_START=""
if [[ "$HAS_DB" == "true" ]]; then
  DB_START="if [[ -f docker-compose.yml || -f compose.yaml || -f compose.yml ]]; then docker compose up -d; fi"
fi

OUT_DIR=$(scratch_dir "bootstrap")
TMPL="${DX_SKILL_DIR}/assets/templates/bootstrap.sh.tmpl"
[[ -f "$TMPL" ]] || die "Template missing: $TMPL"

render_template "$TMPL" "${OUT_DIR}/bootstrap.sh" \
  "INSTALL_CMD=${INSTALL_CMD}" \
  "PY_INSTALL=${PY_INSTALL}" \
  "RUST_BUILD=${RUST_BUILD}" \
  "GO_INSTALL=${GO_INSTALL}" \
  "DB_START=${DB_START}"

chmod +x "${OUT_DIR}/bootstrap.sh"

log "Wrote bootstrap to ${OUT_DIR}/bootstrap.sh"
printf '%s\n' "$OUT_DIR"
