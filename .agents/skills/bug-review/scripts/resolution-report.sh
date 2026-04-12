#!/usr/bin/env bash
# resolution-report.sh — Aggregate resolution rate statistics
# Part of: bug-review
# Purpose: Generates resolution rate report across all tracked PRs.
#          Shows overall rate, by severity, by category, and trends.
#
# Usage: $0 [--json]
#   --json: output JSON instead of markdown
# Exit codes: 0 = success, 1 = error, 2 = no data
set -euo pipefail

FORMAT="markdown"
[[ "${1:-}" == "--json" ]] && FORMAT="json"

STORE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data}/bug-review/findings"

if [[ ! -d "$STORE_DIR" ]]; then
  echo "No bug-review data found. Run /bug-review on a PR first." >&2
  exit 2
fi

# Collect all PR files that have resolutions
RESOLVED_FILES=$(find "$STORE_DIR" -name "pr-*.json" -exec grep -l '"resolutions"' {} + 2>/dev/null || true)

if [[ -z "$RESOLVED_FILES" ]]; then
  echo "No resolution data found. Run /bug-review:resolve on a merged PR first." >&2
  exit 2
fi

# Aggregate all resolution data
TOTAL_FINDINGS=0
TOTAL_RESOLVED=0
TOTAL_UNRESOLVED=0
TOTAL_INCONCLUSIVE=0
PRS_ANALYZED=0

# Per-severity and per-category accumulators (stored as temp files)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

while IFS= read -r file; do
  [[ -f "$file" ]] || continue

  HAS_RESOLUTIONS=$(jq 'has("resolutions") and .resolutions != null and .resolutions.results != null' "$file" 2>/dev/null)
  [[ "$HAS_RESOLUTIONS" == "true" ]] || continue

  ((PRS_ANALYZED++))

  # Extract findings with their resolutions
  jq -c '.findings as $findings | .resolutions.results[] as $res |
    ($findings | to_entries[] | select(
      (.value.id // ("F" + (.key | tostring))) == $res.id
    ) | .value) as $finding |
    {
      severity: ($finding.severity // "UNKNOWN"),
      category: ($finding.category // "unknown"),
      status: $res.status
    }' "$file" 2>/dev/null >> "$TMPDIR/all_resolutions.jsonl" || true

  # Count per-status
  R=$(jq '.resolutions.summary.resolved // 0' "$file")
  U=$(jq '.resolutions.summary.unresolved // 0' "$file")
  I=$(jq '.resolutions.summary.inconclusive // 0' "$file")
  T=$(jq '.resolutions.summary.total // 0' "$file")

  TOTAL_FINDINGS=$((TOTAL_FINDINGS + T))
  TOTAL_RESOLVED=$((TOTAL_RESOLVED + R))
  TOTAL_UNRESOLVED=$((TOTAL_UNRESOLVED + U))
  TOTAL_INCONCLUSIVE=$((TOTAL_INCONCLUSIVE + I))
done <<< "$RESOLVED_FILES"

# Calculate overall rate
if [[ $TOTAL_FINDINGS -gt 0 ]]; then
  OVERALL_RATE=$(echo "scale=1; $TOTAL_RESOLVED * 100 / $TOTAL_FINDINGS" | bc)
else
  OVERALL_RATE="0.0"
fi

# Calculate per-severity rates
SEVERITY_REPORT="[]"
for severity in CRITICAL HIGH MEDIUM LOW; do
  SEV_TOTAL=$(grep -c "\"severity\":\"$severity\"" "$TMPDIR/all_resolutions.jsonl" 2>/dev/null || echo "0")
  SEV_RESOLVED=$(grep "\"severity\":\"$severity\"" "$TMPDIR/all_resolutions.jsonl" 2>/dev/null | grep -c '"status":"RESOLVED"' || echo "0")

  if [[ "$SEV_TOTAL" -gt 0 ]]; then
    SEV_RATE=$(echo "scale=1; $SEV_RESOLVED * 100 / $SEV_TOTAL" | bc)
  else
    SEV_RATE="0.0"
  fi

  SEVERITY_REPORT=$(echo "$SEVERITY_REPORT" | jq \
    --arg sev "$severity" --arg total "$SEV_TOTAL" \
    --arg resolved "$SEV_RESOLVED" --arg rate "$SEV_RATE" \
    '. + [{"severity": $sev, "total": ($total|tonumber), "resolved": ($resolved|tonumber), "rate": ($rate|tonumber)}]')
done

# Calculate per-category rates
CATEGORY_REPORT="[]"
if [[ -f "$TMPDIR/all_resolutions.jsonl" ]]; then
  CATEGORIES=$(jq -r '.category' "$TMPDIR/all_resolutions.jsonl" 2>/dev/null | sort -u || true)

  while IFS= read -r cat; do
    [[ -z "$cat" ]] && continue
    CAT_TOTAL=$(grep -c "\"category\":\"$cat\"" "$TMPDIR/all_resolutions.jsonl" 2>/dev/null || echo "0")
    CAT_RESOLVED=$(grep "\"category\":\"$cat\"" "$TMPDIR/all_resolutions.jsonl" 2>/dev/null | grep -c '"status":"RESOLVED"' || echo "0")

    if [[ "$CAT_TOTAL" -gt 0 ]]; then
      CAT_RATE=$(echo "scale=1; $CAT_RESOLVED * 100 / $CAT_TOTAL" | bc)
    else
      CAT_RATE="0.0"
    fi

    CATEGORY_REPORT=$(echo "$CATEGORY_REPORT" | jq \
      --arg cat "$cat" --arg total "$CAT_TOTAL" \
      --arg resolved "$CAT_RESOLVED" --arg rate "$CAT_RATE" \
      '. + [{"category": $cat, "total": ($total|tonumber), "resolved": ($resolved|tonumber), "rate": ($rate|tonumber)}]')
  done <<< "$CATEGORIES"
fi

# Sort categories by rate (ascending — worst performers first)
CATEGORY_REPORT=$(echo "$CATEGORY_REPORT" | jq 'sort_by(.rate)')

if [[ "$FORMAT" == "json" ]]; then
  jq -n \
    --arg prs "$PRS_ANALYZED" \
    --arg total "$TOTAL_FINDINGS" \
    --arg resolved "$TOTAL_RESOLVED" \
    --arg unresolved "$TOTAL_UNRESOLVED" \
    --arg inconclusive "$TOTAL_INCONCLUSIVE" \
    --arg rate "$OVERALL_RATE" \
    --argjson severity "$SEVERITY_REPORT" \
    --argjson category "$CATEGORY_REPORT" \
    '{
      prs_analyzed: ($prs|tonumber),
      overall: {
        total: ($total|tonumber),
        resolved: ($resolved|tonumber),
        unresolved: ($unresolved|tonumber),
        inconclusive: ($inconclusive|tonumber),
        resolution_rate: ($rate|tonumber)
      },
      by_severity: $severity,
      by_category: $category
    }'
else
  echo "# Bug Review Resolution Report"
  echo ""
  echo "**PRs analyzed:** $PRS_ANALYZED"
  echo "**Overall resolution rate:** ${OVERALL_RATE}%"
  echo ""
  echo "| Metric | Count |"
  echo "|--------|-------|"
  echo "| Total findings | $TOTAL_FINDINGS |"
  echo "| Resolved | $TOTAL_RESOLVED |"
  echo "| Unresolved | $TOTAL_UNRESOLVED |"
  echo "| Inconclusive | $TOTAL_INCONCLUSIVE |"
  echo ""
  echo "## By Severity"
  echo ""
  echo "| Severity | Total | Resolved | Rate |"
  echo "|----------|-------|----------|------|"
  echo "$SEVERITY_REPORT" | jq -r '.[] | "| \(.severity) | \(.total) | \(.resolved) | \(.rate)% |"'
  echo ""
  echo "## By Category"
  echo ""
  echo "| Category | Total | Resolved | Rate |"
  echo "|----------|-------|----------|------|"
  echo "$CATEGORY_REPORT" | jq -r '.[] | "| \(.category) | \(.total) | \(.resolved) | \(.rate)% |"'
fi
