#!/bin/bash
# check_eval1_no_isadmin.sh — No finding targets the isAdmin function
OUTPUT_DIR="$1"
FINDINGS="$OUTPUT_DIR/findings.json"

if [[ ! -f "$FINDINGS" ]]; then
  echo "FAIL: findings.json not found in $OUTPUT_DIR"
  exit 1
fi

MATCHES=$(jq '(if type == "array" then . else .findings end) | [.[] | select(.title + .description | test("isAdmin"; "i"))] | length' "$FINDINGS" 2>/dev/null)

if [[ "$MATCHES" -eq 0 ]]; then
  echo "PASS: No findings target isAdmin (correct — it's clean)"
  exit 0
else
  echo "FAIL: $MATCHES finding(s) incorrectly flag isAdmin"
  exit 1
fi
