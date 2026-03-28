#!/usr/bin/env bash
# fetch-pr.sh — Fetch PR diff and metadata as JSON
# Part of: bug-review
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pr-number-or-url>" >&2
  echo "  Accepts: PR number (42), URL (https://github.com/.../pull/42), or branch name" >&2
  exit 1
fi

PR_INPUT="$1"

# Verify gh is authenticated before any gh calls
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh CLI is not authenticated" >&2
  echo "Hint: Run 'gh auth login' to authenticate" >&2
  exit 1
fi

# Resolve PR number from various input formats
if [[ "$PR_INPUT" =~ ^https://github\.com/.*/pull/([0-9]+) ]]; then
  PR_NUMBER="${BASH_REMATCH[1]}"
elif [[ "$PR_INPUT" =~ ^[0-9]+$ ]]; then
  PR_NUMBER="$PR_INPUT"
else
  # Try to resolve branch name to PR number
  PR_NUMBER=$(gh pr view "$PR_INPUT" --json number --jq '.number' 2>/dev/null) || {
    echo "Error: Could not find an open PR for '$PR_INPUT'" >&2
    echo "Hint: Check that the PR exists and is open with 'gh pr list'" >&2
    exit 1
  }
fi

# Fetch PR metadata (use 'files' for file paths, 'changedFiles' is just a count)
PR_META=$(gh pr view "$PR_NUMBER" --json number,title,body,baseRefName,headRefName,files,additions,deletions 2>/dev/null) || {
  echo "Error: Could not fetch PR #$PR_NUMBER" >&2
  echo "Hint: Make sure the PR exists and you have access to the repository" >&2
  exit 1
}

# Fetch PR diff into a temp file (avoids ARG_MAX limits on large PRs)
DIFF_TMP=$(mktemp)
trap 'rm -f "$DIFF_TMP"' EXIT

gh pr diff "$PR_NUMBER" > "$DIFF_TMP" 2>/dev/null || {
  echo "Error: Could not fetch diff for PR #$PR_NUMBER" >&2
  exit 1
}

# Combine metadata and diff into a single JSON output
echo "$PR_META" | jq --rawfile diff "$DIFF_TMP" '. + {diff: $diff}'
