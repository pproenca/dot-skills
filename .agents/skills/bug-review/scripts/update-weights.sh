#!/usr/bin/env bash
# update-weights.sh — Learn category weights from resolution rate data
# Part of: bug-review
# Purpose: The optimization loop. Categories with low resolution rates
#          (findings that developers don't fix) are likely false-positive-heavy.
#          This script adjusts category_weights in config.json based on actual
#          resolution data, so future reviews deprioritize noisy categories.
#
# Usage: $0 [config-path]
#   config-path: path to config.json (default: auto-detect from skill dir)
# Exit codes: 0 = success, 1 = error, 2 = insufficient data
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
CONFIG_PATH="${1:-$SCRIPT_DIR/../config.json}"

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Error: config.json not found at $CONFIG_PATH" >&2
  exit 1
fi

# Get resolution report as JSON
REPORT=$(bash "$SCRIPT_DIR/resolution-report.sh" --json 2>/dev/null) || {
  echo "Error: Could not generate resolution report. Need at least 1 resolved PR." >&2
  exit 2
}

TOTAL_FINDINGS=$(echo "$REPORT" | jq '.overall.total')
PRS_ANALYZED=$(echo "$REPORT" | jq '.prs_analyzed')

# Require minimum data before adjusting weights
MIN_FINDINGS=10
MIN_PRS=3

if [[ "$TOTAL_FINDINGS" -lt "$MIN_FINDINGS" || "$PRS_ANALYZED" -lt "$MIN_PRS" ]]; then
  echo "Insufficient data for weight learning (need $MIN_FINDINGS+ findings across $MIN_PRS+ PRs)." >&2
  echo "  Current: $TOTAL_FINDINGS findings across $PRS_ANALYZED PRs" >&2
  exit 2
fi

# Compute weights from category resolution rates
# Weight = resolution_rate / 100, clamped to [0.1, 1.0]
# Categories below 30% resolution rate get minimum weight (0.1)
CATEGORY_WEIGHTS=$(echo "$REPORT" | jq '
  .by_category | map({
    key: .category,
    value: (
      if .total < 3 then 1.0  # Not enough data, keep default
      elif .rate < 30 then 0.1  # Likely false-positive-heavy, suppress
      else (.rate / 100)  # Scale 0-100% to 0-1.0
      end
    )
  }) | from_entries
')

echo "Category weights computed from $TOTAL_FINDINGS findings across $PRS_ANALYZED PRs:"
echo "$CATEGORY_WEIGHTS" | jq -r 'to_entries[] | "  \(.key): \(.value)"'

# Update config.json with new weights
jq --argjson weights "$CATEGORY_WEIGHTS" '.category_weights = $weights' "$CONFIG_PATH" > "${CONFIG_PATH}.tmp" \
  && mv "${CONFIG_PATH}.tmp" "$CONFIG_PATH"

echo ""
echo "Updated $CONFIG_PATH with learned category weights."

# Flag suppressed categories
SUPPRESSED=$(echo "$CATEGORY_WEIGHTS" | jq -r 'to_entries[] | select(.value <= 0.1) | .key')
if [[ -n "$SUPPRESSED" ]]; then
  echo ""
  echo "WARNING: These categories have been suppressed (resolution rate < 30%):"
  while IFS= read -r cat; do
    RATE=$(echo "$REPORT" | jq -r --arg c "$cat" '.by_category[] | select(.category == $c) | .rate')
    echo "  - $cat (${RATE}% resolution rate)"
  done <<< "$SUPPRESSED"
  echo "  They will have minimal impact on future review scoring."
fi
