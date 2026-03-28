#!/bin/bash
# check_eval1_trigger_scenarios.sh — Every finding has a non-empty triggerScenario
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

# Handle both flat array and {findings: [...]} wrapper
TOTAL=$(jq '(if type == "array" then . else .findings end) | length' "$FINDINGS" 2>/dev/null)
MISSING=$(jq '(if type == "array" then . else .findings end) | [.[] | select(.triggerScenario == null or .triggerScenario == "")] | length' "$FINDINGS" 2>/dev/null)

if [[ "$TOTAL" -eq 0 ]]; then
  echo "FAIL: No findings to check"
  exit 1
fi

if [[ "$MISSING" -eq 0 ]]; then
  echo "PASS: All $TOTAL findings have non-empty triggerScenario"
  exit 0
else
  echo "FAIL: $MISSING of $TOTAL findings missing triggerScenario"
  exit 1
fi
