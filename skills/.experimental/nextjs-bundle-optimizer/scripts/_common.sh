#!/usr/bin/env bash
# _common.sh — shared helpers for nextjs-bundle-optimizer scripts.
# Sourced, not executed. Use: source "$(dirname "$0")/_common.sh"
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${CLAUDE_PLUGIN_DATA:-$SKILL_DIR}/config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config.json not found at $CONFIG_FILE" >&2
  echo "Run: bash scripts/baseline.sh --setup" >&2
  exit 1
fi

require_jq() {
  command -v jq >/dev/null 2>&1 || {
    echo "ERROR: jq is required. Install: brew install jq" >&2
    exit 1
  }
}

cfg() {
  jq -r --arg k "$1" '.[$k] // empty' "$CONFIG_FILE"
}

PKG_MANAGER="$(cfg package_manager)"
APP_DIR="$(cfg app_dir)"
BUILD_CMD="$(cfg build_command)"
TEST_CMD="$(cfg test_command)"
TYPECHECK_CMD="$(cfg typecheck_command)"
BUDGET_DIR="$(cfg budget_dir)"

PKG_MANAGER="${PKG_MANAGER:-npm}"
APP_DIR="${APP_DIR:-.}"
BUILD_CMD="${BUILD_CMD:-${PKG_MANAGER} run build}"
TEST_CMD="${TEST_CMD:-${PKG_MANAGER} test}"
TYPECHECK_CMD="${TYPECHECK_CMD:-npx tsc --noEmit}"
BUDGET_DIR="${BUDGET_DIR:-.bundle-budgets}"

ensure_clean_git() {
  pushd "$APP_DIR" >/dev/null
  if [[ -n "$(git status --porcelain 2>/dev/null || true)" ]]; then
    echo "ERROR: working tree is dirty. Commit or stash before measuring." >&2
    echo "Reason: an iteration's result must be attributable to a single change." >&2
    popd >/dev/null
    exit 1
  fi
  popd >/dev/null
}

detect_next_version() {
  pushd "$APP_DIR" >/dev/null
  local v
  v="$(jq -r '.dependencies.next // .devDependencies.next // empty' package.json 2>/dev/null || true)"
  popd >/dev/null
  echo "${v#^}" | awk -F. '{print $1}'
}

detect_bundler() {
  pushd "$APP_DIR" >/dev/null
  local major
  major="$(detect_next_version || echo 0)"
  if [[ "$major" -ge 16 ]]; then
    echo "turbopack"
  else
    local turbo
    turbo="$(jq -r '.scripts.build // empty' package.json | grep -c -- '--turbopack' || true)"
    if [[ "$turbo" -gt 0 ]]; then
      echo "turbopack"
    else
      echo "webpack"
    fi
  fi
  popd >/dev/null
}

now_iso() { date -u +"%Y-%m-%dT%H-%M-%SZ"; }

human_bytes() {
  awk -v b="$1" 'BEGIN{
    units="B KB MB GB"; split(units,u," ");
    i=1; while(b>=1024 && i<4){b/=1024; i++}
    printf("%.1f %s\n", b, u[i])
  }'
}
