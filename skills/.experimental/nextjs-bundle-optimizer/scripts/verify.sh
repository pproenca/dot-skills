#!/usr/bin/env bash
# verify.sh — Hard verification: build + types + tests + no overall regression.
# Usage: bash scripts/verify.sh
# Exit 0 = safe to commit. Exit 1 = revert.
set -euo pipefail

source "$(dirname "$0")/_common.sh"
require_jq

cd "$APP_DIR"

PASS=0
FAIL=0

# Note on arithmetic: ((PASS++)) returns exit 1 when PASS starts at 0 (post-increment
# of 0), which trips `set -e`. Use PASS=$((PASS+1)) instead.

run_check() {
  local label="$1"; shift
  echo "→ $label"
  if "$@"; then
    echo "  PASS: $label"
    PASS=$((PASS+1))
  else
    echo "  FAIL: $label"
    FAIL=$((FAIL+1))
  fi
}

# 1. Build (cold for a fair comparison; skip if measure.sh already left a fresh .next)
if [[ ! -f .next/build-manifest.json ]] && [[ ! -f .next/app-build-manifest.json ]]; then
  rm -rf .next
  run_check "next build" bash -c "$BUILD_CMD"
else
  echo "→ Skipping rebuild (fresh .next/ from measure.sh)"
  PASS=$((PASS+1))
fi

# 2. Type check — counts as FAIL if it fails (no `|| true` swallowing).
run_check "typecheck ($TYPECHECK_CMD)" bash -c "$TYPECHECK_CMD"

# 3. Tests (only if a test command is configured AND there are test files)
if [[ -n "$TEST_CMD" ]]; then
  if find . -maxdepth 4 -type d \( -name node_modules -o -name .next -o -name .git \) -prune -o \
       -type f \( -name '*.test.*' -o -name '*.spec.*' \) -print -quit 2>/dev/null | grep -q .; then
    run_check "tests ($TEST_CMD)" bash -c "$TEST_CMD"
  else
    echo "→ No test files detected; skipping $TEST_CMD"
    PASS=$((PASS+1))
  fi
fi

# 4. No overall bundle regression vs baseline
if [[ -d "$SKILL_DIR/baselines/current" ]]; then
  echo "→ Bundle regression check vs baselines/current"
  # compare.sh exits 1 on regression. Don't let set -e abort us before we record FAIL.
  set +e
  bash "$SKILL_DIR/scripts/compare.sh" >/dev/null
  cmp_exit=$?
  set -e
  if [[ $cmp_exit -eq 0 ]]; then
    echo "  PASS: no overall regression"
    PASS=$((PASS+1))
  else
    echo "  FAIL: overall bundle grew. See: bash scripts/compare.sh"
    FAIL=$((FAIL+1))
  fi
else
  echo "→ No baseline yet; skipping regression check"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "Verify FAILED. Recommended action: git revert the last change and try a different recipe."
  exit 1
fi

echo ""
echo "Verify PASSED. Safe to commit."
echo "Suggested: git add -A && git commit -m 'optim: <recipe applied>'"
exit 0
