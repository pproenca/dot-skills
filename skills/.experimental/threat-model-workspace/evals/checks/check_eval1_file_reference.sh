#!/bin/bash
# check_eval1_file_reference.sh — Verify review_template.html is specifically referenced
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

if grep -q "review_template" "$FILE"; then
  echo "PASS: Output references review_template.html"
  exit 0
else
  echo "FAIL: No reference to review_template.html"
  exit 1
fi
