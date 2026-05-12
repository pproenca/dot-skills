#!/usr/bin/env bash
# compare.sh — Diff a measurement against the baseline.
# Usage:
#   bash scripts/compare.sh                          # latest iteration vs baselines/current
#   bash scripts/compare.sh <baseline> <current>     # explicit paths
# Exit codes:
#   0 = improvement or no change
#   1 = overall regression (per-route increases beyond budget OR total grew)
#   2 = baseline or current missing
set -euo pipefail

source "$(dirname "$0")/_common.sh"
require_jq

BASELINE_DIR="${1:-$SKILL_DIR/baselines/current}"
CURRENT_DIR="${2:-}"

if [[ -z "$CURRENT_DIR" ]]; then
  CURRENT_DIR="$(ls -td "$SKILL_DIR"/iterations/*/ 2>/dev/null | head -n1 || true)"
fi

if [[ ! -f "$BASELINE_DIR/bundle.json" ]]; then
  echo "ERROR: baseline bundle.json missing at $BASELINE_DIR" >&2
  echo "Run: bash scripts/baseline.sh" >&2
  exit 2
fi
if [[ -z "$CURRENT_DIR" ]] || [[ ! -f "${CURRENT_DIR%/}/bundle.json" ]]; then
  echo "ERROR: current bundle.json missing." >&2
  echo "Run: bash scripts/measure.sh" >&2
  exit 2
fi
CURRENT_DIR="${CURRENT_DIR%/}"

echo "→ Comparing"
echo "  baseline: $BASELINE_DIR"
echo "  current:  $CURRENT_DIR"
echo ""

# Per-route delta — show top changes by absolute size.
RESULT=$(
node - "$BASELINE_DIR/bundle.json" "$CURRENT_DIR/bundle.json" <<'NODE'
const fs = require('fs');
const b = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const c = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const routes = new Set([...Object.keys(b.routes||{}), ...Object.keys(c.routes||{})]);
const deltas = [];
let totalB = 0, totalC = 0;
for (const r of routes){
  const before = b.routes[r]?.bytes ?? 0;
  const after  = c.routes[r]?.bytes ?? 0;
  totalB += before; totalC += after;
  if (before === after) continue;
  deltas.push({ route: r, before, after, delta: after - before, pct: before === 0 ? 100 : ((after - before)/before * 100) });
}
deltas.sort((a,b) => Math.abs(b.delta) - Math.abs(a.delta));
const overall = totalC - totalB;
const overallPct = totalB === 0 ? 0 : (overall / totalB * 100);
function fmt(n){ const s = n>=0?'+':''; if (Math.abs(n)>=1024*1024) return `${s}${(n/1024/1024).toFixed(2)} MB`; if (Math.abs(n)>=1024) return `${s}${(n/1024).toFixed(1)} KB`; return `${s}${n} B`; }
console.log(`Total: ${(totalB/1024).toFixed(1)} KB → ${(totalC/1024).toFixed(1)} KB  (${fmt(overall)}, ${overallPct.toFixed(1)}%)`);
console.log('');
console.log('Top 15 route deltas:');
for (const d of deltas.slice(0, 15)){
  const arrow = d.delta < 0 ? '↓' : '↑';
  console.log(`  ${arrow} ${fmt(d.delta).padEnd(12)} ${d.pct.toFixed(1).padStart(6)}%   ${d.route}`);
}
console.log('');
// Timing delta if available
try {
  const tb = JSON.parse(fs.readFileSync(process.argv[2].replace('bundle.json','timing.json'), 'utf8'));
  const tc = JSON.parse(fs.readFileSync(process.argv[3].replace('bundle.json','timing.json'), 'utf8'));
  const td = (tc.build_seconds||0) - (tb.build_seconds||0);
  console.log(`Build time: ${tb.build_seconds}s → ${tc.build_seconds}s  (${td>=0?'+':''}${td}s)`);
} catch {}
// Machine-readable summary for callers
process.stderr.write(JSON.stringify({ overall_bytes_delta: overall, overall_pct: overallPct, regressions: deltas.filter(d=>d.delta>0), wins: deltas.filter(d=>d.delta<0) }) + '\n');
process.exit(overall > 0 ? 1 : 0);
NODE
)
EXIT=$?
echo "$RESULT"
exit $EXIT
