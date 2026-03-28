#!/bin/bash
# check_eval2_csv_untrusted.sh — Verify CSV input identified as untrusted
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

if grep -qi "csv\|finding" "$FILE" && grep -qi "untrust\|attacker.control\|malicious" "$FILE"; then
  echo "PASS: CSV/findings identified as potentially untrusted input"
  exit 0
else
  echo "FAIL: CSV input not identified as untrusted"
  exit 1
fi
