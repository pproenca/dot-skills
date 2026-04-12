#!/usr/bin/env bash
# post-review.sh — Post findings as a GitHub PR review with inline comments
# Part of: bug-review
# Exit codes: 0 = review posted, 1 = error, 2 = no findings to post (skipped)
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <pr-number> <findings-json-file>" >&2
  echo "  findings-json-file: path to JSON file with array of findings" >&2
  exit 1
fi

PR_NUMBER="$1"
FINDINGS_FILE="$2"

if [[ ! -f "$FINDINGS_FILE" ]]; then
  echo "Error: Findings file not found: $FINDINGS_FILE" >&2
  exit 1
fi

FINDINGS_COUNT=$(jq 'length' "$FINDINGS_FILE")

if [[ "$FINDINGS_COUNT" -eq 0 ]]; then
  echo "No findings to post. Skipping review."
  exit 2
fi

# Get the latest commit SHA on the PR (required for creating review)
COMMIT_SHA=$(gh pr view "$PR_NUMBER" --json headRefOid --jq '.headRefOid')

# Build severity summary
CRITICAL_COUNT=$(jq '[.[] | select(.severity == "CRITICAL")] | length' "$FINDINGS_FILE")
HIGH_COUNT=$(jq '[.[] | select(.severity == "HIGH")] | length' "$FINDINGS_FILE")
MEDIUM_COUNT=$(jq '[.[] | select(.severity == "MEDIUM")] | length' "$FINDINGS_FILE")
LOW_COUNT=$(jq '[.[] | select(.severity == "LOW")] | length' "$FINDINGS_FILE")

REVIEW_BODY="## Bug Review Summary

Found **${FINDINGS_COUNT}** issue(s): ${CRITICAL_COUNT} critical, ${HIGH_COUNT} high, ${MEDIUM_COUNT} medium, ${LOW_COUNT} low.

<!-- [bug-review] automated review -->"

# Build inline comments from findings
COMMENTS=$(jq -c '[.[] | {
  path: .file,
  line: .line,
  body: (
    "**" + .severity + "**: " + .title + "\n\n" +
    .description + "\n\n" +
    "**Trigger scenario**: " + .triggerScenario + "\n\n" +
    (if .suggestedFix then ("**Suggested fix**: " + .suggestedFix + "\n\n") else "" end) +
    "<!-- [bug-review] -->"
  )
}]' "$FINDINGS_FILE")

# Create the review via GitHub API
PAYLOAD=$(jq -n \
  --arg body "$REVIEW_BODY" \
  --arg sha "$COMMIT_SHA" \
  --argjson comments "$COMMENTS" \
  '{
    commit_id: $sha,
    body: $body,
    event: "COMMENT",
    comments: $comments
  }')

echo "$PAYLOAD" | gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews" \
  --input - \
  --method POST >/dev/null 2>&1 || {
  echo "Error: Failed to post review on PR #$PR_NUMBER" >&2
  echo "Hint: Check that your gh token has write permission on the repository" >&2
  exit 1
}

echo "Posted review with $FINDINGS_COUNT finding(s) on PR #$PR_NUMBER"
