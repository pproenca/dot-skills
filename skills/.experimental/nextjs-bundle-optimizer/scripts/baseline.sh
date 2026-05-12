#!/usr/bin/env bash
# baseline.sh — Establish the reference snapshot for bundle size + build time.
# Usage:
#   bash scripts/baseline.sh            # measure baseline
#   bash scripts/baseline.sh --setup    # interactively populate config.json
#   bash scripts/baseline.sh --dry-run  # print what would happen, no build
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${1:-}" == "--setup" ]]; then
  CONFIG_FILE="${CLAUDE_PLUGIN_DATA:-$SKILL_DIR}/config.json"
  if [[ -f "$CONFIG_FILE" ]] && [[ -n "$(jq -r '.app_dir // empty' "$CONFIG_FILE" 2>/dev/null)" ]]; then
    echo "config.json already populated at $CONFIG_FILE"
    echo "Edit it directly to change values, or delete and re-run --setup."
    exit 0
  fi
  echo "Setup is intended to be driven by the agent via AskUserQuestion."
  echo "Required fields: package_manager, app_dir, build_command, test_command, typecheck_command, budget_dir"
  echo "See config.json _setup_instructions for guidance."
  exit 0
fi

source "$(dirname "$0")/_common.sh"
require_jq

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

cd "$APP_DIR"

ensure_clean_git

BUNDLER="$(detect_bundler)"
NEXT_MAJOR="$(detect_next_version)"
TS="$(now_iso)"
OUT_DIR="$SKILL_DIR/baselines/$TS"

echo "→ Baseline run: $TS"
echo "  app_dir:    $APP_DIR"
echo "  bundler:    $BUNDLER"
echo "  next major: $NEXT_MAJOR"
echo "  output:     $OUT_DIR"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "(dry-run) would: rm -rf .next && $BUILD_CMD && save snapshot"
  exit 0
fi

mkdir -p "$OUT_DIR"

echo "→ Clearing .next/ for a cold build (baseline must be reproducible)"
rm -rf .next

echo "→ Running production build"
BUILD_LOG="$OUT_DIR/build.log"
build_start=$(date +%s)
if ! bash -c "$BUILD_CMD" 2>&1 | tee "$BUILD_LOG"; then
  echo "ERROR: baseline build failed. Fix the build before baselining." >&2
  exit 1
fi
build_end=$(date +%s)
build_duration=$((build_end - build_start))

echo "→ Build OK in ${build_duration}s. Running bundle analyzer."
ANALYZE_OUT=".next/diagnostics/analyze"

if [[ "$BUNDLER" == "turbopack" ]] && [[ "$NEXT_MAJOR" -ge 16 ]]; then
  if ! npx next experimental-analyze --output 2>&1 | tee -a "$BUILD_LOG"; then
    echo "WARN: experimental-analyze failed; falling back to manifest-only snapshot." >&2
    ANALYZE_OUT=""
  fi
else
  echo "  Detected non-Turbopack project. Skipping experimental-analyze."
  echo "  For webpack mode, install @next/bundle-analyzer and re-run with ANALYZE=true."
  ANALYZE_OUT=""
fi

# Capture artifacts the comparison step relies on.
if [[ -n "$ANALYZE_OUT" ]] && [[ -d "$ANALYZE_OUT" ]]; then
  cp -R "$ANALYZE_OUT" "$OUT_DIR/analyze"
fi

# build-manifest.json: route → chunk list. Available for both bundlers.
[[ -f .next/build-manifest.json ]] && cp .next/build-manifest.json "$OUT_DIR/build-manifest.json"
[[ -f .next/app-build-manifest.json ]] && cp .next/app-build-manifest.json "$OUT_DIR/app-build-manifest.json"

# Sum chunk sizes per route from the manifest. This is what we'll diff iteration-over-iteration.
node - <<'NODE' > "$OUT_DIR/bundle.json"
const fs = require('fs');
const path = require('path');
const root = process.cwd();
function readJson(p){ try{ return JSON.parse(fs.readFileSync(p,'utf8')); }catch{ return null; } }
const buildManifest = readJson(path.join(root, '.next/build-manifest.json')) || {};
const appBuildManifest = readJson(path.join(root, '.next/app-build-manifest.json')) || {};
const staticDir = path.join(root, '.next/static');
function fileSize(rel){
  const p = path.join(root, '.next', rel.replace(/^\/_next\//, '').replace(/^_next\//,''));
  try { return fs.statSync(p).size; } catch { return 0; }
}
function sumRoute(chunks){
  return (chunks||[]).reduce((acc, c) => acc + fileSize(c), 0);
}
const routes = {};
for (const [route, chunks] of Object.entries(buildManifest.pages || {})) {
  routes[`pages:${route}`] = { chunks: chunks.length, bytes: sumRoute(chunks) };
}
for (const [route, chunks] of Object.entries(appBuildManifest.pages || {})) {
  routes[`app:${route}`] = { chunks: chunks.length, bytes: sumRoute(chunks) };
}
process.stdout.write(JSON.stringify({ routes, ts: new Date().toISOString() }, null, 2));
NODE

# Timing snapshot
jq -n \
  --arg ts "$TS" \
  --arg bundler "$BUNDLER" \
  --argjson build_seconds "$build_duration" \
  '{ts: $ts, bundler: $bundler, build_seconds: $build_seconds, cache: "cold"}' \
  > "$OUT_DIR/timing.json"

# Mark this as the current baseline (symlink for quick reference)
ln -sfn "$OUT_DIR" "$SKILL_DIR/baselines/current"

echo ""
echo "✓ Baseline saved to $OUT_DIR"
echo "  build_seconds: ${build_duration}"
echo "  routes:        $(jq '.routes | length' "$OUT_DIR/bundle.json")"
echo ""
echo "Next: bash scripts/analyze.sh"
