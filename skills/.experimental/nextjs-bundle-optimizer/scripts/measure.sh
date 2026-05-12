#!/usr/bin/env bash
# measure.sh — Re-build and re-measure after applying a change.
# Usage:
#   bash scripts/measure.sh [iteration-name]
#   bash scripts/measure.sh --warm   # do NOT delete .next; measures incremental build
# Default: cold build (rm -rf .next) for apples-to-apples vs the baseline.
set -euo pipefail

source "$(dirname "$0")/_common.sh"
require_jq

cd "$APP_DIR"

WARM=0
ITER_NAME=""
for arg in "$@"; do
  case "$arg" in
    --warm) WARM=1 ;;
    --dry-run) echo "(dry-run) would: build, analyze, write iteration snapshot"; exit 0 ;;
    *) ITER_NAME="$arg" ;;
  esac
done
ITER_NAME="${ITER_NAME:-$(now_iso)}"

OUT_DIR="$SKILL_DIR/iterations/$ITER_NAME"
mkdir -p "$OUT_DIR"

BUNDLER="$(detect_bundler)"
NEXT_MAJOR="$(detect_next_version)"

echo "→ Measure run: $ITER_NAME ($BUNDLER)"
if [[ $WARM -eq 0 ]]; then
  echo "  Cold build (rm -rf .next)"
  rm -rf .next
else
  echo "  Warm build (reusing existing .next/cache)"
fi

BUILD_LOG="$OUT_DIR/build.log"
build_start=$(date +%s)
if ! bash -c "$BUILD_CMD" 2>&1 | tee "$BUILD_LOG"; then
  echo "ERROR: build failed. This means the most recent change broke the build." >&2
  echo "Action: revert and try a different recipe." >&2
  jq -n --arg ts "$ITER_NAME" '{ts:$ts, status:"build_failed"}' > "$OUT_DIR/timing.json"
  exit 1
fi
build_end=$(date +%s)
build_duration=$((build_end - build_start))

jq -n \
  --arg ts "$ITER_NAME" \
  --arg bundler "$BUNDLER" \
  --argjson build_seconds "$build_duration" \
  --arg cache "$([[ $WARM -eq 1 ]] && echo warm || echo cold)" \
  '{ts:$ts, bundler:$bundler, build_seconds:$build_seconds, cache:$cache, status:"ok"}' \
  > "$OUT_DIR/timing.json"

# Delegate the bundle snapshot + findings extraction to analyze.sh.
bash "$SKILL_DIR/scripts/analyze.sh" "$ITER_NAME"

echo ""
echo "✓ Measurement complete: $OUT_DIR"
echo "  build_seconds: ${build_duration}"
echo ""
echo "Next: bash scripts/compare.sh"
