#!/usr/bin/env bash
# store-findings.sh — Persist findings to durable storage for resolution tracking
# Part of: bug-review
# Purpose: Save review findings so we can later measure whether they were
#          resolved at merge time (the resolution rate feedback loop).
#
# Usage: $0 <pr-number> <findings-json-file> <review-commit>
# Exit codes: 0 = success, 1 = error
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <pr-number> <findings-json-file> <review-commit>" >&2
  echo "  Stores findings to \${CLAUDE_PLUGIN_DATA}/bug-review/findings/" >&2
  exit 1
fi

PR_NUMBER="$1"
FINDINGS_FILE="$2"
REVIEW_COMMIT="$3"

if [[ ! -f "$FINDINGS_FILE" ]]; then
  echo "Error: Findings file not found: $FINDINGS_FILE" >&2
  exit 1
fi

# Determine storage directory
STORE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data}/bug-review/findings"
mkdir -p "$STORE_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get repo info for context
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "unknown")

# Read findings and wrap with metadata
FINDINGS=$(jq '
  if type == "array" then .
  elif .findings then .findings
  else []
  end
' "$FINDINGS_FILE")

FINDINGS_COUNT=$(echo "$FINDINGS" | jq 'length')

# Build the stored record
jq -n \
  --arg pr "$PR_NUMBER" \
  --arg repo "$REPO" \
  --arg commit "$REVIEW_COMMIT" \
  --arg timestamp "$TIMESTAMP" \
  --argjson count "$FINDINGS_COUNT" \
  --argjson findings "$FINDINGS" \
  '{
    pr: ($pr | tonumber),
    repo: $repo,
    reviewCommit: $commit,
    postedAt: $timestamp,
    findingsCount: $count,
    findings: $findings,
    resolutions: null
  }' > "$STORE_DIR/pr-${PR_NUMBER}.json"

echo "Stored $FINDINGS_COUNT findings for PR #$PR_NUMBER at $STORE_DIR/pr-${PR_NUMBER}.json"
