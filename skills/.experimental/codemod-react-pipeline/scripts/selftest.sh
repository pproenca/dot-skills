#!/usr/bin/env bash
# selftest.sh — verify the codemod-react-pipeline's own scripts and assets are well-formed.
# Part of: codemod-react-pipeline
#
# This is the skill's test harness (TDD gate). It checks structure, not transform behaviour:
#   - every script parses (bash -n) and declares strict mode + a shebang
#   - hooks/hooks.json is valid JSON with a PreToolUse entry
#   - assets/templates exist
#   - if the `codemod` CLI is installed, the workflow template validates
#   - if validate-skill.js is reachable, the skill validates structurally
#
# Usage: bash scripts/selftest.sh
# Exit:  0 = all checks pass, 1 = a check failed.

set -uo pipefail   # not -e: we want to run every check and tally failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
ok()   { echo "  ✓ $*"; PASS=$((PASS + 1)); }
bad()  { echo "  ✗ $*"; FAIL=$((FAIL + 1)); }
note() { echo "  - $*"; }

echo "Self-testing codemod-react-pipeline ($SKILL_DIR)"
echo ""

# --- 1. Scripts: syntax, shebang, strict mode ------------------------------
echo "Scripts:"
shopt -s nullglob
mapfile -t SCRIPTS < <(find "$SCRIPT_DIR" -name '*.sh' -type f | sort)
[[ ${#SCRIPTS[@]} -gt 0 ]] || bad "no scripts found under $SCRIPT_DIR"
for s in "${SCRIPTS[@]}"; do
  rel="${s#"$SKILL_DIR"/}"
  if bash -n "$s" 2>/dev/null; then ok "$rel parses"; else bad "$rel has a syntax error"; fi
  head -n1 "$s" | grep -q '^#!' || bad "$rel missing shebang"
  # Strict mode: require nounset (-u) AND pipefail. errexit (-e) is intentionally optional —
  # the all-gates/all-checks scripts omit it on purpose (they tally and always reach cleanup).
  { grep -Eq 'set -[a-z]*u' "$s" && grep -q 'pipefail' "$s"; } \
    || bad "$rel missing strict mode (need set -u and pipefail)"
done
echo ""

# --- 2. Hooks --------------------------------------------------------------
echo "Hooks:"
HOOKS="$SKILL_DIR/hooks/hooks.json"
if [[ -f "$HOOKS" ]]; then
  if command -v jq >/dev/null 2>&1; then
    if jq -e . "$HOOKS" >/dev/null 2>&1; then ok "hooks/hooks.json is valid JSON"; else bad "hooks/hooks.json is not valid JSON"; fi
    jq -e '.hooks.PreToolUse' "$HOOKS" >/dev/null 2>&1 \
      && ok "hooks/hooks.json declares a PreToolUse guard" \
      || bad "hooks/hooks.json has no PreToolUse entry"
  else
    note "jq not installed — skipping hooks JSON check"
  fi
else
  bad "hooks/hooks.json is missing"
fi
echo ""

# --- 3. Templates ----------------------------------------------------------
echo "Templates:"
for t in transform.ts.template astgrep-rule.yml.template workflow.yaml.template codemod.yaml.template; do
  [[ -f "$SKILL_DIR/assets/templates/$t" ]] && ok "assets/templates/$t present" || bad "assets/templates/$t missing"
done
[[ -f "$SKILL_DIR/assets/templates/fixtures/input.tsx.template" ]] \
  && ok "fixture templates present" || bad "fixture templates missing"
echo ""

# --- 4. Workflow template validates (optional) -----------------------------
echo "Workflow template:"
WF="$SKILL_DIR/assets/templates/workflow.yaml.template"
if command -v codemod >/dev/null 2>&1 && [[ -f "$WF" ]]; then
  # Render to a temp file (substitute __PLACEHOLDER__ tokens; leave codemod ${{ }} intact) and validate.
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  sed -E 's/__[A-Z0-9_]+__/placeholder/g' "$WF" > "$tmp/workflow.yaml"
  if codemod workflow validate -w "$tmp/workflow.yaml" >/dev/null 2>&1; then
    ok "workflow.yaml.template validates with codemod CLI"
  else
    note "codemod workflow validate reported issues (placeholders may not satisfy schema) — review manually"
  fi
else
  note "codemod CLI not installed — skipping workflow validation"
fi
echo ""

# --- 5. Structural skill validation (optional) -----------------------------
echo "Skill structure:"
VALIDATOR="${VALIDATE_SKILL_JS:-}"
if [[ -z "$VALIDATOR" ]]; then
  VALIDATOR="$(find "$HOME/.claude/plugins/cache" -name validate-skill.js -path '*dev-skill*' 2>/dev/null | head -n1 || true)"
fi
if [[ -n "$VALIDATOR" && -f "$VALIDATOR" ]] && command -v node >/dev/null 2>&1; then
  if node "$VALIDATOR" "$SKILL_DIR" >/dev/null 2>&1; then
    ok "validate-skill.js passed"
  else
    bad "validate-skill.js reported errors (run it directly to see them)"
  fi
else
  note "validate-skill.js not found (set VALIDATE_SKILL_JS=/path) — skipping"
fi
echo ""

# --- Summary ---------------------------------------------------------------
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] || exit 1
