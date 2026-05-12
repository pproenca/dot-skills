#!/usr/bin/env bash
# analyze.sh — Run the bundle analyzer and extract top offenders.
# Usage: bash scripts/analyze.sh [iteration-name]
# Defaults iteration-name to a timestamp. Output: iterations/{name}/findings.json
set -euo pipefail

source "$(dirname "$0")/_common.sh"
require_jq

cd "$APP_DIR"

ITER_NAME="${1:-$(now_iso)}"
OUT_DIR="$SKILL_DIR/iterations/$ITER_NAME"
mkdir -p "$OUT_DIR"

BUNDLER="$(detect_bundler)"
NEXT_MAJOR="$(detect_next_version)"

echo "→ Analyze run: $ITER_NAME ($BUNDLER, next $NEXT_MAJOR)"

if [[ ! -d .next ]]; then
  echo "ERROR: .next/ missing. Run scripts/baseline.sh or scripts/measure.sh first." >&2
  exit 1
fi

if [[ "$BUNDLER" == "turbopack" ]] && [[ "$NEXT_MAJOR" -ge 16 ]]; then
  if [[ ! -d .next/diagnostics/analyze ]]; then
    echo "→ Running next experimental-analyze --output"
    npx next experimental-analyze --output
  fi
  if [[ -d .next/diagnostics/analyze ]]; then
    cp -R .next/diagnostics/analyze "$OUT_DIR/analyze"
  fi
else
  echo "→ Turbopack analyzer not available (webpack mode or Next < 16)."
  echo "  Using build-manifest only. Install @next/bundle-analyzer for richer data."
fi

# Build findings.json — the structured input for diagnose.sh.
# We work from build-manifest data which is always available.
node - "$OUT_DIR" <<'NODE'
const fs = require('fs');
const path = require('path');
const outDir = process.argv[2];
const root = process.cwd();
function readJson(p){ try{ return JSON.parse(fs.readFileSync(p,'utf8')); }catch{ return null; } }

const buildManifest = readJson(path.join(root, '.next/build-manifest.json')) || {};
const appBuildManifest = readJson(path.join(root, '.next/app-build-manifest.json')) || {};

function fileSize(rel){
  const p = path.join(root, '.next', rel.replace(/^\/_next\//,'').replace(/^_next\//,''));
  try { return fs.statSync(p).size; } catch { return 0; }
}

// Per-chunk size index
const chunkSizes = {};
const seen = new Set();
function indexChunks(map){
  for (const chunks of Object.values(map || {})) {
    for (const c of (chunks || [])) {
      if (seen.has(c)) continue;
      seen.add(c);
      chunkSizes[c] = fileSize(c);
    }
  }
}
indexChunks(buildManifest.pages);
indexChunks(appBuildManifest.pages);

// Chunks used by many routes (shared / framework)
const usage = {};
function tallyUsage(map){
  for (const [route, chunks] of Object.entries(map || {})) {
    for (const c of (chunks || [])) {
      usage[c] = usage[c] || { routes: new Set(), bytes: chunkSizes[c] || 0 };
      usage[c].routes.add(route);
    }
  }
}
tallyUsage(buildManifest.pages);
tallyUsage(appBuildManifest.pages);

const topChunks = Object.entries(chunkSizes)
  .sort((a,b) => b[1] - a[1])
  .slice(0, 20)
  .map(([chunk, bytes]) => ({
    chunk,
    bytes,
    used_by_routes: Array.from(usage[chunk]?.routes || []).slice(0, 8),
    route_count: (usage[chunk]?.routes.size) || 0,
  }));

// Heaviest routes
function routeWeights(map, prefix){
  return Object.entries(map || {}).map(([route, chunks]) => ({
    route: `${prefix}${route}`,
    bytes: (chunks || []).reduce((a, c) => a + (chunkSizes[c] || 0), 0),
    chunk_count: (chunks || []).length,
  }));
}
const heaviestRoutes = [
  ...routeWeights(buildManifest.pages, 'pages:'),
  ...routeWeights(appBuildManifest.pages, 'app:'),
].sort((a,b) => b.bytes - a.bytes).slice(0, 15);

// Hints to feed diagnose.sh
const hints = [];
for (const c of topChunks.slice(0, 10)) {
  if (c.route_count >= 3) hints.push({ kind: 'shared-heavy', chunk: c.chunk, bytes: c.bytes, route_count: c.route_count });
  else hints.push({ kind: 'route-heavy', chunk: c.chunk, bytes: c.bytes, used_by_routes: c.used_by_routes });
}

// Treemap JSON, if Turbopack analyzer produced it (best-effort — schema is experimental)
const treemapJson = path.join(outDir, 'analyze', 'data.json');
let treemap = null;
if (fs.existsSync(treemapJson)) {
  treemap = readJson(treemapJson);
}

fs.writeFileSync(
  path.join(outDir, 'findings.json'),
  JSON.stringify({
    iteration: path.basename(outDir),
    ts: new Date().toISOString(),
    top_chunks: topChunks,
    heaviest_routes: heaviestRoutes,
    hints,
    has_treemap: !!treemap,
  }, null, 2)
);
NODE

# Build a structured bundle.json snapshot matching baseline format (for compare.sh)
node - "$OUT_DIR" <<'NODE'
const fs = require('fs');
const path = require('path');
const outDir = process.argv[2];
const root = process.cwd();
function readJson(p){ try{ return JSON.parse(fs.readFileSync(p,'utf8')); }catch{ return null; } }
const buildManifest = readJson(path.join(root, '.next/build-manifest.json')) || {};
const appBuildManifest = readJson(path.join(root, '.next/app-build-manifest.json')) || {};
function fileSize(rel){
  const p = path.join(root, '.next', rel.replace(/^\/_next\//,'').replace(/^_next\//,''));
  try { return fs.statSync(p).size; } catch { return 0; }
}
function sumRoute(chunks){ return (chunks||[]).reduce((a,c) => a + fileSize(c), 0); }
const routes = {};
for (const [route, chunks] of Object.entries(buildManifest.pages || {})) {
  routes[`pages:${route}`] = { chunks: chunks.length, bytes: sumRoute(chunks) };
}
for (const [route, chunks] of Object.entries(appBuildManifest.pages || {})) {
  routes[`app:${route}`] = { chunks: chunks.length, bytes: sumRoute(chunks) };
}
fs.writeFileSync(path.join(outDir, 'bundle.json'), JSON.stringify({ routes, ts: new Date().toISOString() }, null, 2));
NODE

echo ""
echo "✓ Findings saved to $OUT_DIR/findings.json"
echo ""
jq -r '
  "Top chunks (largest):",
  (.top_chunks[:5] | .[] | "  \(.bytes | tostring) B  \(.chunk)  (×\(.route_count) routes)"),
  "",
  "Heaviest routes:",
  (.heaviest_routes[:5] | .[] | "  \(.bytes | tostring) B  \(.route) (\(.chunk_count) chunks)")
' "$OUT_DIR/findings.json"

echo ""
echo "Next: bash scripts/diagnose.sh $OUT_DIR/findings.json"
