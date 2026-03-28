#!/bin/bash
# check_eval3_proportionate.sh — Verify output is proportionate (under 200 lines)
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

lines=$(wc -l < "$FILE" | tr -d ' ')
if [[ "$lines" -le 200 ]]; then
  echo "PASS: Output is $lines lines (proportionate for low-risk scripts)"
  exit 0
else
  echo "FAIL: Output is $lines lines (disproportionately long for simple validation scripts)"
  exit 1
fi
