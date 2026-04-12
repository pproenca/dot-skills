#!/usr/bin/env bash
# dedup.sh — Find existing [bug-review] comments on a PR for deduplication
# Part of: bug-review
# Purpose: Extracts prior bug-review findings by location (file + line)
#          so the main agent can match by proximity, not text similarity.
#
# Usage: $0 <pr-number>
# Output: JSON array of {id, path, line, category, created_at}
# Exit codes: 0 = success (may return empty array)
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pr-number>" >&2
  exit 1
fi

PR_NUMBER="$1"

# Fetch all review comments (inline comments on diff)
REVIEW_COMMENTS=$(gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" --paginate 2>/dev/null) || {
  echo "[]"
  exit 0
}

# Filter for [bug-review] tagged comments and extract location + category
# The category is extracted from the comment body pattern "**SEVERITY**: title"
echo "$REVIEW_COMMENTS" | jq '[
  .[] | select(.body | contains("[bug-review]")) |
  {
    id: .id,
    path: .path,
    line: (.line // .original_line),
    category: (
      .body | capture("\\*\\*(?<sev>[A-Z]+)\\*\\*: (?<title>.+?)\\n") |
      .title // "unknown"
    ),
    severity: (
      .body | capture("\\*\\*(?<sev>[A-Z]+)\\*\\*:") | .sev // "UNKNOWN"
    ),
    created_at: .created_at
  }
]'
