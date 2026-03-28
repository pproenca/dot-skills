#!/bin/bash
# check_eval2_injection_found.sh — At least one finding identifies injection
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

MATCHES=$(jq '(if type == "array" then . else .findings end) | [.[] | select((.title + .description + (.category // "")) | test("inject|sql.?inject|xss"; "i"))] | length' "$FINDINGS" 2>/dev/null)

if [[ "$MATCHES" -ge 1 ]]; then
  echo "PASS: Found $MATCHES finding(s) identifying injection"
  exit 0
else
  echo "FAIL: No findings identify injection vulnerability"
  exit 1
fi
