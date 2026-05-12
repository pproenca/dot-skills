#!/usr/bin/env bash
# diagnose.sh — Map findings to optimization recipes.
# Usage: bash scripts/diagnose.sh [path/to/findings.json]
# Defaults to the most recent iteration's findings.json.
# Output: stdout — prioritized recipe list with pointers into references/optimizations.md.
set -euo pipefail

source "$(dirname "$0")/_common.sh"
require_jq

FINDINGS="${1:-}"
if [[ -z "$FINDINGS" ]]; then
  FINDINGS="$(ls -td "$SKILL_DIR"/iterations/*/findings.json 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$FINDINGS" ]] || [[ ! -f "$FINDINGS" ]]; then
  echo "ERROR: no findings.json. Run scripts/analyze.sh first." >&2
  exit 1
fi

echo "→ Diagnosing $FINDINGS"
echo ""

# Look at top chunks and heaviest routes, classify each, suggest a recipe.
# Classification is heuristic; the agent should still verify by inspecting
# the analyzer treemap or the import chain.

node - "$FINDINGS" <<'NODE'
const fs = require('fs');
const findings = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

const recipes = [];

// Heuristic: very large shared chunk used by ≥3 routes → barrel-import or polyfill bloat
// Heuristic: huge route-specific chunk → check for accidental client component / heavy dep
// Heuristic: many small chunks → fine, ignore

function fmt(n){
  if (n >= 1024*1024) return `${(n/1024/1024).toFixed(2)} MB`;
  if (n >= 1024) return `${(n/1024).toFixed(1)} KB`;
  return `${n} B`;
}

const SHARED_THRESHOLD = 100 * 1024;     // 100 KB
const ROUTE_THRESHOLD  = 200 * 1024;     // 200 KB
const DOMINANT_CHUNK   = 50 * 1024;      // a single chunk >50KB is worth investigating

for (const c of findings.top_chunks) {
  if (c.bytes < DOMINANT_CHUNK) continue;
  const shared = c.route_count >= 3;
  const isPolyfillish = /polyfill|core-js|legacy/i.test(c.chunk);
  const isFramework  = /framework|main|webpack-runtime|polyfills/i.test(c.chunk);

  if (isFramework && !isPolyfillish) {
    recipes.push({
      priority: 'LOW',
      finding: `${fmt(c.bytes)} framework chunk: ${c.chunk}`,
      recipe: 'framework-chunks',
      why: 'Framework chunks are mostly fixed cost. Only worth touching if extraordinarily large.',
    });
    continue;
  }
  if (isPolyfillish) {
    recipes.push({
      priority: 'HIGH',
      finding: `${fmt(c.bytes)} polyfill-related chunk: ${c.chunk}`,
      recipe: 'polyfill-bloat',
      why: 'Polyfills compound across routes. Tightening browserslist usually has the biggest single-change impact.',
    });
    continue;
  }
  if (shared && c.bytes > SHARED_THRESHOLD) {
    recipes.push({
      priority: 'HIGH',
      finding: `${fmt(c.bytes)} shared chunk used by ${c.route_count} routes: ${c.chunk}`,
      recipe: 'shared-heavy-dep',
      why: 'A heavy dep imported across many routes multiplies the cost. Investigate import chain in the analyzer treemap.',
    });
    continue;
  }
  if (!shared && c.bytes > ROUTE_THRESHOLD) {
    recipes.push({
      priority: 'MEDIUM',
      finding: `${fmt(c.bytes)} route-specific chunk: ${c.chunk} (routes: ${c.used_by_routes.join(', ')})`,
      recipe: 'heavy-client-component',
      why: 'Could be a wrong-side import (server lib in client) or a candidate for next/dynamic + ssr:false.',
    });
    continue;
  }
}

// Per-route weight checks
for (const r of findings.heaviest_routes.slice(0, 5)) {
  if (r.bytes > 500 * 1024) {
    recipes.push({
      priority: 'HIGH',
      finding: `${fmt(r.bytes)} route bundle: ${r.route}`,
      recipe: 'large-route-bundle',
      why: 'Routes over ~500KB hurt LCP/TTI on mobile. Open the analyzer treemap for this route and look at the largest module.',
    });
  } else if (r.bytes > 250 * 1024) {
    recipes.push({
      priority: 'MEDIUM',
      finding: `${fmt(r.bytes)} route bundle: ${r.route}`,
      recipe: 'large-route-bundle',
      why: 'Approaching the warning threshold; opportunistic optimization worthwhile.',
    });
  }
}

if (recipes.length === 0) {
  console.log('No obvious offenders. Bundle is in good shape.');
  console.log('Consider build-time optimizations — see references/optimizations.md#build-time.');
  process.exit(0);
}

// Sort by priority HIGH > MEDIUM > LOW
const order = { HIGH: 0, MEDIUM: 1, LOW: 2 };
recipes.sort((a,b) => order[a.priority] - order[b.priority]);

console.log('Recommended recipes (apply ONE at a time, then measure + verify):');
console.log('');
for (let i = 0; i < recipes.length; i++) {
  const r = recipes[i];
  console.log(`${i+1}. [${r.priority}] ${r.finding}`);
  console.log(`   Recipe:  references/optimizations.md#${r.recipe}`);
  console.log(`   Why:     ${r.why}`);
  console.log('');
}

console.log('After applying one recipe:');
console.log('  bash scripts/measure.sh');
console.log('  bash scripts/compare.sh');
console.log('  bash scripts/verify.sh');
NODE
