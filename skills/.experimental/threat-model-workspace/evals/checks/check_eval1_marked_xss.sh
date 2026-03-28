#!/bin/bash
# check_eval1_marked_xss.sh — Verify the XSS via marked.parse is identified
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

if grep -qi "marked\|markdown.*render\|innerHTML.*sanitiz\|XSS\|cross.site" "$FILE"; then
  echo "PASS: Output identifies markdown rendering / XSS risk"
  exit 0
else
  echo "FAIL: No mention of marked/markdown rendering XSS risk"
  exit 1
fi
