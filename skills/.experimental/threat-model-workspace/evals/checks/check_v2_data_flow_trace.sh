#!/bin/bash
# check_v2_data_flow_trace.sh — Verify output contains a data flow trace
# A trace shows entry → function chain → sink with arrows or step numbering
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

# Look for trace indicators: arrows (→, ↓, -->), "Entry:", "Sink:", "TRACE:", or numbered flow steps
if grep -qP '(→|↓|-->|TRACE:|Entry:.*Sink:|step \d|Phase \d)' "$FILE" 2>/dev/null || \
   grep -qi 'data.flow\|trace.*entry.*sink\|entry.point.*→\|flows.*through\|passes.*to\|forwarded.*to.*without.*validat' "$FILE"; then
  echo "PASS: Output contains data flow trace indicators"
  exit 0
else
  echo "FAIL: No data flow trace found (no →/↓ arrows, no TRACE: labels, no entry-to-sink documentation)"
  exit 1
fi
