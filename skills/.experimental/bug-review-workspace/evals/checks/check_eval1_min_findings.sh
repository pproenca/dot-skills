#!/bin/bash
# check_eval1_min_findings.sh — At least 3 CRITICAL or HIGH findings
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

# Handle both flat array and {findings: [...]} wrapper; case-insensitive severity
COUNT=$(jq '(if type == "array" then . else .findings end) | [.[] | select(.severity | ascii_downcase | test("critical|high"))] | length' "$FINDINGS" 2>/dev/null)

if [[ "$COUNT" -ge 3 ]]; then
  echo "PASS: Found $COUNT CRITICAL/HIGH findings (>= 3 required)"
  exit 0
else
  echo "FAIL: Found $COUNT CRITICAL/HIGH findings (>= 3 required)"
  exit 1
fi
