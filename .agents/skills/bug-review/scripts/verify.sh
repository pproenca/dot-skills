#!/usr/bin/env bash
# verify.sh — Verify bug review was posted successfully
# Part of: bug-review
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pr-number>" >&2
  exit 1
fi

PR_NUMBER="$1"

PASS=0
FAIL=0

assert_true() {
  local label="$1" condition="$2"
  if [[ "$condition" == "true" ]]; then
    echo "  PASS: $label"
    ((PASS++))
  else
    echo "  FAIL: $label"
    ((FAIL++))
  fi
}

# Check that at least one [bug-review] review exists on the PR
REVIEWS_RAW=$(gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews" --paginate 2>&1) || {
  echo "  ERROR: Could not fetch reviews — API call failed: $REVIEWS_RAW" >&2
  exit 1
}
REVIEW_COUNT=$(echo "$REVIEWS_RAW" | jq '[.[] | select(.body | contains("[bug-review]"))] | length')

assert_true "At least one [bug-review] review exists" \
  "$([ "$REVIEW_COUNT" -gt 0 ] && echo true || echo false)"

# Check that review comments exist
COMMENTS_RAW=$(gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" --paginate 2>&1) || {
  echo "  ERROR: Could not fetch comments — API call failed: $COMMENTS_RAW" >&2
  exit 1
}
COMMENT_COUNT=$(echo "$COMMENTS_RAW" | jq '[.[] | select(.body | contains("[bug-review]"))] | length')

assert_true "Review has inline comments" \
  "$([ "$COMMENT_COUNT" -gt 0 ] && echo true || echo false)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
echo "Reviews: $REVIEW_COUNT, Inline comments: $COMMENT_COUNT"
[[ $FAIL -eq 0 ]] || exit 1
