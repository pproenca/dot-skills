#!/bin/bash
# check_eval1_structure.sh — Verify 4-section structure exists
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found in outputs"
  exit 1
fi

missing=()
grep -qi "overview" "$FILE" || missing+=("Overview")
grep -qi "trust.boundar" "$FILE" || missing+=("Trust boundaries")
grep -qi "attack.surface" "$FILE" || missing+=("Attack surfaces")
grep -qi "criticality\|calibration" "$FILE" || missing+=("Criticality calibration")

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "PASS: All 4 sections found (Overview, Trust boundaries, Attack surfaces, Criticality)"
  exit 0
else
  echo "FAIL: Missing sections: ${missing[*]}"
  exit 1
fi
