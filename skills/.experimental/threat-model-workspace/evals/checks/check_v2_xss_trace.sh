#!/bin/bash
# check_v2_xss_trace.sh — Verify the XSS finding includes a specific trace path
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

# Must mention both marked.parse AND innerHTML/DOM in the same finding context
if grep -qi 'marked' "$FILE" && grep -qi 'innerHTML\|DOM\|sanitiz' "$FILE"; then
  # Check for specificity: line numbers, function names, or file references
  if grep -qi 'line \|:\d\|review_template\|generate_review' "$FILE"; then
    echo "PASS: XSS finding includes specific trace with code references"
    exit 0
  else
    echo "FAIL: XSS mentioned but without specific code references (line numbers, file names)"
    exit 1
  fi
else
  echo "FAIL: No marked.parse → innerHTML trace found"
  exit 1
fi
