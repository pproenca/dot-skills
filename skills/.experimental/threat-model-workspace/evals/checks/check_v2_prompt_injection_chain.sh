#!/bin/bash
# check_v2_prompt_injection_chain.sh — Verify prompt injection chain is identified
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

# Must identify the chain: CSV content → agent context → code modification
if grep -qi 'prompt.inject\|indirect.inject\|CSV.*inject\|finding.*description.*inject\|CSV.*influence.*patch\|CSV.*manipulat' "$FILE"; then
  echo "PASS: Identifies prompt injection via CSV content"
  exit 0
else
  echo "FAIL: No prompt injection chain identified (CSV → agent → code modification)"
  exit 1
fi
