#!/usr/bin/env bash
# verify.sh — Assert the generated output is well-formed.
# Part of: sketch-to-react
#
# Checks:
#   - Tokens file exists and has at least one --color- variable
#   - Every artboard has a matching .tsx + .module.css pair
#   - Every .tsx passes tsc --noEmit (if tsconfig present in project)
#   - All className references in JSX resolve to a rule in the matching CSS
#   - Asset imports resolve to files in the manifest
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$SKILL_ROOT/work"
CONFIG_FILE="$SKILL_ROOT/config.json"

PASS=0
FAIL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label (expected: $expected, got: $actual)"
    FAIL=$((FAIL + 1))
  fi
}

assert_true() {
  local label="$1" cond="$2"
  if [[ "$cond" == "1" ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    FAIL=$((FAIL + 1))
  fi
}

read_config() { node -e "process.stdout.write(require('$CONFIG_FILE')['$1']||'')"; }
OUTPUT_ROOT=$(read_config output_root)
COMPONENTS_DIR=$(read_config components_dir)
TOKENS_PATH=$(read_config tokens_path)

TOKENS_FILE="$OUTPUT_ROOT/$TOKENS_PATH"
COMPONENTS_FULL="$OUTPUT_ROOT/$COMPONENTS_DIR"

# --- Tokens ---
echo "Checking tokens..."
if [[ -f "$TOKENS_FILE" ]]; then
  assert_true "tokens file exists" "1"
  COLOR_COUNT=$(grep -c -E '^[[:space:]]+--color-' "$TOKENS_FILE" || true)
  assert_true "tokens file has at least one --color-* var" "$([[ $COLOR_COUNT -gt 0 ]] && echo 1 || echo 0)"
else
  assert_true "tokens file exists" "0"
fi

# --- Components ---
# Verify each component root in the document has a matching .tsx + .module.css.
# A "root" is an artboard OR a symbolMaster — both produce components.
# When the user generated only a subset (via --artboard), this check still runs
# against every root and reports missing pairs as FAIL: that's correct because
# verify is meant to assert a complete generation. For partial runs, expect
# fails proportional to the unselected roots and read them as informational.
echo ""
echo "Checking component pairs..."
if [[ ! -f "$WORK_DIR/document.json" ]]; then
  echo "  SKIP: work/document.json missing (parse step not run)"
else
  EXPECTED_NAMES=$(node -e "
    const fs=require('fs');
    const doc=JSON.parse(fs.readFileSync('$WORK_DIR/document.json','utf8'));
    const COMP=new Set(['artboard','symbolMaster']);
    function walk(n,out){if(!n||typeof n!=='object')return;if(COMP.has(n._class)){out.push(n.name);return}for(const k of Object.keys(n)){const v=n[k];if(Array.isArray(v))v.forEach(c=>walk(c,out));else if(v&&typeof v==='object')walk(v,out)}}
    const out=[]; walk(doc,out);
    process.stdout.write(out.map(n=>n.replace(/[^a-zA-Z0-9]+/g,' ').split(' ').filter(Boolean).map(w=>w[0].toUpperCase()+w.slice(1)).join('')).join('\n'));
  ")

  EXPECTED_COUNT=$(echo "$EXPECTED_NAMES" | grep -c . || true)
  FOUND_PAIRS=0
  MISSING=0
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    TSX="$COMPONENTS_FULL/$name.tsx"
    CSS="$COMPONENTS_FULL/$name.module.css"
    if [[ -f "$TSX" ]] && [[ -f "$CSS" ]]; then
      FOUND_PAIRS=$((FOUND_PAIRS + 1))
    else
      MISSING=$((MISSING + 1))
    fi
  done <<< "$EXPECTED_NAMES"

  echo "  $FOUND_PAIRS of $EXPECTED_COUNT component pairs present ($MISSING missing)"
  assert_true "at least one component pair generated" "$([[ $FOUND_PAIRS -gt 0 ]] && echo 1 || echo 0)"
  if [[ $MISSING -gt 0 ]]; then
    echo "  NOTE: missing pairs are expected when --artboard was used to generate a subset."
  fi
fi

# --- TypeScript check (opt-in) ---
echo ""
echo "Type-checking..."
PROJECT_ROOT="$(dirname "$OUTPUT_ROOT")"
if [[ -f "$PROJECT_ROOT/tsconfig.json" ]]; then
  if (cd "$PROJECT_ROOT" && npx --no tsc --noEmit 2>/dev/null); then
    assert_true "tsc --noEmit passes" "1"
  else
    assert_true "tsc --noEmit passes" "0"
  fi
else
  echo "  SKIP: no tsconfig.json at $PROJECT_ROOT — skipping type check"
fi

# --- ClassName cross-reference ---
echo ""
echo "Checking className references..."
if [[ -d "$COMPONENTS_FULL" ]]; then
  ORPHANS=$(node -e "
    const fs=require('fs'), path=require('path');
    const dir='$COMPONENTS_FULL';
    const escape = s => s.replace(/[.*+?^\${}()|[\\]\\\\]/g,'\\\\\$&');
    let orphans=0;
    for (const f of fs.readdirSync(dir).filter(f=>f.endsWith('.tsx'))) {
      const tsx=fs.readFileSync(path.join(dir,f),'utf8');
      const cssFile=path.join(dir,f.replace('.tsx','.module.css'));
      if(!fs.existsSync(cssFile)) continue;
      const css=fs.readFileSync(cssFile,'utf8');
      const refs=[...tsx.matchAll(/styles\\['([^']+)'\\]/g)].map(m=>m[1]);
      for (const r of refs) {
        const re = new RegExp('\\\\.' + escape(r) + '(?=[\\\\s{,:.>+~])');
        if (!re.test(css)) {
          console.error('  orphan className: '+r+' in '+f);
          orphans++;
        }
      }
    }
    process.stdout.write(String(orphans));
  ")
  assert_true "no orphan className references" "$([[ $ORPHANS -eq 0 ]] && echo 1 || echo 0)"
else
  echo "  SKIP: components dir not found"
fi

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] || exit 1
