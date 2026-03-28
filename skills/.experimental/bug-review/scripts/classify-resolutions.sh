#!/usr/bin/env bash
# classify-resolutions.sh — Classify whether findings were resolved at merge time
# Part of: bug-review
# Purpose: The core of the resolution rate feedback loop. Compares code at
#          review time vs merge time to determine if flagged bugs were fixed.
#
# Usage: $0 <pr-number>
# Exit codes: 0 = success, 1 = error, 2 = PR not merged or no stored findings
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pr-number>" >&2
  exit 1
fi

PR_NUMBER="$1"

# Load stored findings
STORE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data}/bug-review/findings"
FINDINGS_FILE="$STORE_DIR/pr-${PR_NUMBER}.json"

if [[ ! -f "$FINDINGS_FILE" ]]; then
  echo "Error: No stored findings for PR #$PR_NUMBER" >&2
  echo "Hint: Run /bug-review on this PR first, then resolve after merge" >&2
  exit 2
fi

# Check if PR is merged
MERGE_INFO=$(gh pr view "$PR_NUMBER" --json merged,mergeCommit 2>/dev/null) || {
  echo "Error: Could not fetch PR #$PR_NUMBER" >&2
  exit 1
}

IS_MERGED=$(echo "$MERGE_INFO" | jq -r '.merged')
if [[ "$IS_MERGED" != "true" ]]; then
  echo "PR #$PR_NUMBER is not merged yet. Resolve after merge." >&2
  exit 2
fi

MERGE_COMMIT=$(echo "$MERGE_INFO" | jq -r '.mergeCommit.oid')
REVIEW_COMMIT=$(jq -r '.reviewCommit' "$FINDINGS_FILE")
FINDINGS=$(jq '.findings' "$FINDINGS_FILE")
FINDINGS_COUNT=$(echo "$FINDINGS" | jq 'length')

if [[ "$FINDINGS_COUNT" -eq 0 ]]; then
  echo "No findings to classify for PR #$PR_NUMBER"
  exit 0
fi

echo "Classifying $FINDINGS_COUNT findings for PR #$PR_NUMBER"
echo "  Review commit: $REVIEW_COMMIT"
echo "  Merge commit:  $MERGE_COMMIT"

RESOLUTIONS="[]"
RESOLVED=0
UNRESOLVED=0
INCONCLUSIVE=0

# For each finding, check if the code changed at the finding's location
for i in $(seq 0 $((FINDINGS_COUNT - 1))); do
  FINDING=$(echo "$FINDINGS" | jq ".[$i]")
  FILE=$(echo "$FINDING" | jq -r '.file')
  LINE=$(echo "$FINDING" | jq -r '.line')
  TITLE=$(echo "$FINDING" | jq -r '.title')

  echo "  [$((i+1))/$FINDINGS_COUNT] $TITLE ($FILE:$LINE)"

  # Get the diff for this file between review and merge
  FILE_DIFF=$(git diff "$REVIEW_COMMIT".."$MERGE_COMMIT" -- "$FILE" 2>/dev/null || echo "")

  if [[ -z "$FILE_DIFF" ]]; then
    # No changes to this file between review and merge
    STATUS="UNRESOLVED"
    CONFIDENCE="0.9"
    REASONING="File $FILE was not modified between review and merge"
    ((UNRESOLVED++))
  else
    # Check if the specific line range was modified
    # Parse full hunk ranges: @@ -old,count +new,count @@ → expand to all lines in range
    CHANGED_LINES=$(echo "$FILE_DIFF" | grep -oE '@@ -[0-9]+(,[0-9]+)? \+([0-9]+)(,[0-9]+)? @@' | \
      sed -E 's/@@ -[0-9]+(,[0-9]+)? \+([0-9]+),?([0-9]*) @@/\2 \3/' | \
      while read -r start count; do
        count="${count:-1}"
        for ((l=start; l<start+count; l++)); do echo "$l"; done
      done || true)

    LINE_START=$((LINE - 5))
    LINE_END=$((LINE + 10))
    [[ $LINE_START -lt 1 ]] && LINE_START=1

    LINE_CHANGED=false
    while IFS= read -r changed_line; do
      [[ -z "$changed_line" ]] && continue
      if [[ "$changed_line" -ge "$LINE_START" && "$changed_line" -le "$LINE_END" ]]; then
        LINE_CHANGED=true
        break
      fi
    done <<< "$CHANGED_LINES"

    if $LINE_CHANGED; then
      # Code at the finding's location was modified — likely resolved
      STATUS="RESOLVED"
      CONFIDENCE="0.75"
      REASONING="Code at $FILE:$LINE was modified between review ($REVIEW_COMMIT) and merge ($MERGE_COMMIT)"
      ((RESOLVED++))
    else
      # File changed but not at this location — inconclusive
      STATUS="INCONCLUSIVE"
      CONFIDENCE="0.5"
      REASONING="File $FILE was modified but not near line $LINE"
      ((INCONCLUSIVE++))
    fi
  fi

  echo "    → $STATUS (confidence: $CONFIDENCE)"

  RESOLUTIONS=$(echo "$RESOLUTIONS" | jq \
    --arg id "$(echo "$FINDING" | jq -r '.id // ("F" + ('"$i"' | tostring))')" \
    --arg status "$STATUS" \
    --arg confidence "$CONFIDENCE" \
    --arg reasoning "$REASONING" \
    --arg merge_commit "$MERGE_COMMIT" \
    --arg detected_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '. + [{
      id: $id,
      status: $status,
      confidence: ($confidence | tonumber),
      reasoning: $reasoning,
      mergeCommit: $merge_commit,
      detectedAt: $detected_at
    }]')
done

# Calculate resolution rate
TOTAL=$((RESOLVED + UNRESOLVED + INCONCLUSIVE))
if [[ $TOTAL -gt 0 ]]; then
  RATE=$(echo "scale=1; $RESOLVED * 100 / $TOTAL" | bc)
else
  RATE="0.0"
fi

# Update the stored findings with resolutions
jq --argjson resolutions "$RESOLUTIONS" \
  --arg rate "$RATE" \
  --arg merge "$MERGE_COMMIT" \
  '.resolutions = {
    mergeCommit: $merge,
    analyzedAt: (now | todate),
    results: $resolutions,
    summary: {
      total: ($resolutions | length),
      resolved: ([$resolutions[] | select(.status == "RESOLVED")] | length),
      unresolved: ([$resolutions[] | select(.status == "UNRESOLVED")] | length),
      inconclusive: ([$resolutions[] | select(.status == "INCONCLUSIVE")] | length),
      resolutionRate: ($rate | tonumber)
    }
  }' "$FINDINGS_FILE" > "$FINDINGS_FILE.tmp" && mv "$FINDINGS_FILE.tmp" "$FINDINGS_FILE"

echo ""
echo "Resolution Summary for PR #$PR_NUMBER:"
echo "  Resolved:     $RESOLVED"
echo "  Unresolved:   $UNRESOLVED"
echo "  Inconclusive: $INCONCLUSIVE"
echo "  Resolution rate: ${RATE}%"
