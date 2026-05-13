#!/usr/bin/env bash
# scaffold-justfile.sh — emit task-runner entries into a scratch dir
# Part of: dx-harness
#
# Adapts to whatever runner exists: Justfile, Makefile, or package.json scripts.
# Never migrates between runners — extends the one that's already there.
# If none exists, creates a Justfile by default (or whatever preferred_task_runner
# in config.json says).
#
# Output for each variant: a fragment file the user copies into / appends to the
# existing runner. Never overwrites.
#
# Usage:
#   bash scaffold-justfile.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq
[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP="$1"
[[ -f "$FP" ]] || die "Fingerprint file not found: $FP"

TASK_RUNNER=$(jq -r '.task_runner' "$FP")
TEST_RUNNER=$(jq -r '.test_runner // ""' "$FP")
PKG_MGR=$(jq -r '.package_manager // ""' "$FP")
PREFERRED=$(config_get "preferred_task_runner" "auto")

# If no runner exists, pick one
if [[ "$TASK_RUNNER" == "none" ]]; then
  case "$PREFERRED" in
    just)        TASK_RUNNER="just" ;;
    make)        TASK_RUNNER="make" ;;
    npm)         TASK_RUNNER="npm-scripts" ;;
    auto|*)
      # Auto: if package.json exists, use npm-scripts; else just
      if [[ -f "$(jq -r '.repo_root' "$FP")/package.json" ]]; then
        TASK_RUNNER="npm-scripts"
      else
        TASK_RUNNER="just"
      fi
      ;;
  esac
fi

# Pick canonical commands per language for dev/test/watch
DEV_CMD="echo 'TODO: set your dev command'"
TEST_CMD="echo 'TODO: set your test command'"
WATCH_CMD="echo 'TODO: set your test watch command'"

case "$TEST_RUNNER" in
  vitest)      TEST_CMD="vitest run"; WATCH_CMD="vitest" ;;
  jest)        TEST_CMD="jest";       WATCH_CMD="jest --watch" ;;
  mocha)       TEST_CMD="mocha";      WATCH_CMD="mocha --watch" ;;
  playwright)  TEST_CMD="playwright test"; WATCH_CMD="playwright test --ui" ;;
  pytest)      TEST_CMD="pytest";     WATCH_CMD="pytest-watch || pytest" ;;
  cargo-test)  TEST_CMD="cargo test"; WATCH_CMD="cargo watch -x test" ;;
  go-test)     TEST_CMD="go test ./..."; WATCH_CMD="go test -run . ./..." ;;
  npm-test)    TEST_CMD="${PKG_MGR:-npm} test";   WATCH_CMD="${PKG_MGR:-npm} run test:watch" ;;
esac

# Dev command guesses
if [[ -n "$PKG_MGR" ]]; then
  DEV_CMD="${PKG_MGR} run dev"
fi

OUT_DIR=$(scratch_dir "taskrunner")

case "$TASK_RUNNER" in
  just)
    TMPL="${DX_SKILL_DIR}/assets/templates/Justfile.tmpl"
    render_template "$TMPL" "${OUT_DIR}/Justfile" \
      "DEV_CMD=${DEV_CMD}" "TEST_CMD=${TEST_CMD}" "WATCH_CMD=${WATCH_CMD}"
    log "Wrote Justfile fragment to ${OUT_DIR}/Justfile  (append to repo Justfile, do not overwrite)"
    ;;
  make)
    TMPL="${DX_SKILL_DIR}/assets/templates/Makefile.tmpl"
    render_template "$TMPL" "${OUT_DIR}/Makefile" \
      "DEV_CMD=${DEV_CMD}" "TEST_CMD=${TEST_CMD}" "WATCH_CMD=${WATCH_CMD}"
    log "Wrote Makefile fragment to ${OUT_DIR}/Makefile  (append to repo Makefile, do not overwrite)"
    ;;
  npm-scripts)
    # Emit a JSON patch the user can merge into package.json scripts
    jq -n \
      --arg dev "$DEV_CMD" --arg test "$TEST_CMD" --arg watch "$WATCH_CMD" \
      '{scripts: {bootstrap: "./bootstrap.sh", dev: $dev, test: $test, "test:watch": $watch, reset: "./reset.sh", seed: "./seed.sh"}}' \
      > "${OUT_DIR}/package.json.patch"
    log "Wrote package.json scripts patch to ${OUT_DIR}/package.json.patch  (merge into existing scripts)"
    ;;
esac

printf '%s\n' "$OUT_DIR"
