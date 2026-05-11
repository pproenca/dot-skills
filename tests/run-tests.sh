#!/usr/bin/env bash
set -euo pipefail

# Test runner for skills-ref validator
# Usage: ./tests/run-tests.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_REF="$PROJECT_ROOT/scripts/skills-ref"
FIXTURES="$SCRIPT_DIR/fixtures"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

test_case() {
  local name="$1"
  local expected="$2"  # "pass" or "fail"
  local fixture="$3"

  if "$SKILLS_REF" validate "$fixture" > /dev/null 2>&1; then
    result="pass"
  else
    result="fail"
  fi

  if [ "$result" = "$expected" ]; then
    echo -e "${GREEN}✓${NC} $name"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}✗${NC} $name (expected $expected, got $result)"
    FAIL=$((FAIL + 1))
  fi
}

test_to_prompt_cdata_safety() {
  local fixture="$FIXTURES/cdata-terminator"
  local output

  output=$("$SKILLS_REF" to-prompt "$fixture")

  if printf '%s' "$output" | grep -Fq ']]><injected'; then
    echo -e "${RED}✗ CDATA terminator is safely split in to-prompt output${NC}"
    FAIL=$((FAIL + 1))
  else
    echo -e "${GREEN}✓${NC} CDATA terminator is safely split in to-prompt output"
    PASS=$((PASS + 1))
  fi
}

echo ""
echo -e "${BOLD}Running skills-ref tests${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test valid skill
test_case "Valid skill passes" "pass" "$FIXTURES/valid-skill"

# Test invalid names
test_case "Uppercase name fails" "fail" "$FIXTURES/invalid-name-uppercase"
test_case "Consecutive hyphens fail" "fail" "$FIXTURES/invalid-name-consecutive-hyphens"

# Test missing required fields
test_case "Missing description fails" "fail" "$FIXTURES/missing-description"

# Test line count
test_case "Too long SKILL.md fails" "fail" "$FIXTURES/too-long-skill"

# Test description length with folded block scalar (regression: parser used to
# only read the first line of YAML values, so multi-line descriptions bypassed
# the 1024-char limit)
test_case "Folded description over 1024 chars fails" "fail" "$FIXTURES/long-folded-description"

# Test inline YAML comment is stripped before measuring description length
# (regression: hand-rolled parser kept everything after `# ` in the value,
# inflating the apparent length)
test_case "Inline-comment description measures post-strip length" "pass" "$FIXTURES/inline-comment-description"

# Test reference consistency
test_case "Missing reference files fails" "fail" "$FIXTURES/missing-references"

# Test to-prompt XML safety
test_to_prompt_cdata_safety

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}All tests passed: $PASS/$((PASS + FAIL))${NC}"
  exit 0
else
  echo -e "${RED}Tests failed: $PASS passed, $FAIL failed${NC}"
  exit 1
fi
