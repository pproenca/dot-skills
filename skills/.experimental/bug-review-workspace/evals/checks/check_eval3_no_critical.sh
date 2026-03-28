#!/bin/bash
# check_eval3_no_critical.sh — Zero CRITICAL findings on clean code
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

CRITICAL=$(jq '(if type == "array" then . else .findings end) | [.[] | select(.severity | ascii_downcase == "critical")] | length' "$FINDINGS" 2>/dev/null)

if [[ "$CRITICAL" -eq 0 ]]; then
  echo "PASS: Zero CRITICAL findings on clean code"
  exit 0
else
  echo "FAIL: $CRITICAL CRITICAL finding(s) on clean code (false positives)"
  exit 1
fi
