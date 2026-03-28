#!/bin/bash
# check_eval3_no_inflation.sh — Verify no critical/high findings for read-only scripts
OUTPUT_DIR="$1"
FILE="$OUTPUT_DIR/THREAT-MODEL.md"
if [[ ! -f "$FILE" ]]; then
  echo "FAIL: THREAT-MODEL.md not found"
  exit 1
fi

# Check if criticality section has critical or high entries
# Look for "Critical" or "High" as section headers or bold labels in the calibration section
if grep -qi "^\*\*critical\*\*$\|^critical$" "$FILE"; then
  echo "FAIL: Found 'Critical' severity for read-only validation scripts (inflated)"
  exit 1
fi
if grep -qi "^\*\*high\*\*$\|^high$" "$FILE" && grep -Pci "(?:critical|high).*(?:rce|remote|arbitrary code|file overwrite)" "$FILE" 2>/dev/null; then
  echo "FAIL: Found 'High' severity with RCE/overwrite claims for validation scripts (inflated)"
  exit 1
fi
echo "PASS: No inflated critical/high severity findings"
exit 0
