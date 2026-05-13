#!/usr/bin/env bash
# time-to-first-commit.sh — measure TTFC in isolation
# Part of: dx-harness
#
# A single-purpose primitive: clone-equivalent (fresh worktree) → bootstrap → test,
# emit wall-clock JSON. Useful when you want just the metric, without the rest of
# the verify checklist.
#
# Usage:
#   bash time-to-first-commit.sh                       # detect from $PWD
#   bash time-to-first-commit.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq

if [[ $# -ge 1 ]]; then
  FP="$1"
else
  FP=$(mktemp -t dx-fp-XXXXXX.json)
  bash "${SCRIPT_DIR}/discover.sh" > "$FP"
  trap 'rm -f "$FP"' EXIT
fi

BOOTSTRAP=$(jq -r '.bootstrap_command // ""' "$FP")
TEST_RUNNER=$(jq -r '.test_runner' "$FP")

[[ -n "$BOOTSTRAP" ]] || die "No bootstrap command detected — TTFC undefined. Scaffold one first."

# Resolve test command (must be runnable)
case "$TEST_RUNNER" in
  vitest)     TEST_CMD="npx vitest run --reporter=dot --bail=1 --silent" ;;
  jest)       TEST_CMD="npx jest --bail=1 --silent" ;;
  pytest)     TEST_CMD="pytest -x -q" ;;
  cargo-test) TEST_CMD="cargo test --quiet" ;;
  go-test)    TEST_CMD="go test ./..." ;;
  npm-test)   TEST_CMD="npm test --silent" ;;
  *)          TEST_CMD="" ;;
esac

WT=$(scratch_dir "ttfc")
make_worktree "$WT" >/dev/null
register_worktree_cleanup "$WT"

bootstrap_start=$(python3 -c 'import time;print(int(time.time()*1000))')
( cd "$WT" && eval "$BOOTSTRAP" ) >/dev/null 2>&1 || true
bootstrap_end=$(python3 -c 'import time;print(int(time.time()*1000))')

test_start=$bootstrap_end
if [[ -n "$TEST_CMD" ]]; then
  ( cd "$WT" && eval "$TEST_CMD" ) >/dev/null 2>&1 || true
fi
test_end=$(python3 -c 'import time;print(int(time.time()*1000))')

jq -n \
  --argjson bootstrap_ms "$((bootstrap_end - bootstrap_start))" \
  --argjson test_ms "$((test_end - test_start))" \
  --argjson total_ms "$((test_end - bootstrap_start))" \
  --arg bootstrap_cmd "$BOOTSTRAP" \
  --arg test_cmd "${TEST_CMD:-(none)}" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
    schema_version: 1,
    generated_at: $generated_at,
    bootstrap_ms: $bootstrap_ms,
    test_ms: $test_ms,
    total_ms: $total_ms,
    bootstrap_cmd: $bootstrap_cmd,
    test_cmd: $test_cmd
  }'
