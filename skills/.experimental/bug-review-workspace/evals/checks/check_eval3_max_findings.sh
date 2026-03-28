#!/bin/bash
# check_eval3_max_findings.sh — At most 2 findings on clean code
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

TOTAL=$(jq '(if type == "array" then . else .findings end) | length' "$FINDINGS" 2>/dev/null)

if [[ "$TOTAL" -le 2 ]]; then
  echo "PASS: $TOTAL findings on clean code (<= 2 threshold)"
  exit 0
else
  echo "FAIL: $TOTAL findings on clean code (> 2 threshold — too many false positives)"
  exit 1
fi
