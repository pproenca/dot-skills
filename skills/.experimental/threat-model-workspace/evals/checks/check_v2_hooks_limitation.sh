#!/bin/bash
# check_v2_hooks_limitation.sh — Verify hooks noted as mitigation AND its limitation identified
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

if grep -qi 'hook\|PreToolUse' "$FILE"; then
  if grep -qi 'echo\|advisory\|not.block\|warning.only\|does.not.prevent\|do.not.block' "$FILE"; then
    echo "PASS: Hooks noted as mitigation with limitation (advisory/echo-only)"
    exit 0
  else
    echo "FAIL: Hooks mentioned but limitation not identified (echo-only, not blocking)"
    exit 1
  fi
else
  echo "FAIL: No mention of hooks.json or PreToolUse hooks"
  exit 1
fi
