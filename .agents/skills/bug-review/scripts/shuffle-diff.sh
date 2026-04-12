#!/usr/bin/env bash
# shuffle-diff.sh — Randomize file ordering in a unified diff
# Part of: bug-review
# Purpose: Each review pass gets a different file ordering to create
#          attention diversity. Earlier files in a diff get more careful
#          review, so shuffling forces different bugs to the "top."
#
# Usage: $0 <seed> < input.diff > shuffled.diff
# Exit codes: 0 = success, 1 = error, 2 = empty diff
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <seed>" >&2
  echo "  Reads unified diff from stdin, outputs shuffled diff to stdout" >&2
  echo "  seed: integer seed for deterministic shuffling (use pass number)" >&2
  exit 1
fi

SEED="$1"

# Read entire diff from stdin
DIFF=$(cat)

if [[ -z "$DIFF" ]]; then
  echo "Error: Empty diff on stdin" >&2
  exit 2
fi

# Split diff into per-file chunks using "diff --git" as delimiter
# Store each chunk in a temp directory as a numbered file
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

CHUNK_NUM=0
CURRENT_CHUNK=""

while IFS= read -r line; do
  if [[ "$line" =~ ^diff\ --git ]]; then
    # Save previous chunk if exists
    if [[ -n "$CURRENT_CHUNK" ]]; then
      printf '%s\n' "$CURRENT_CHUNK" > "$TMPDIR/chunk_$(printf '%04d' $CHUNK_NUM)"
      ((CHUNK_NUM++))
    fi
    CURRENT_CHUNK="$line"
  else
    if [[ -n "$CURRENT_CHUNK" ]]; then
      CURRENT_CHUNK="$CURRENT_CHUNK"$'\n'"$line"
    fi
  fi
done <<< "$DIFF"

# Save last chunk
if [[ -n "$CURRENT_CHUNK" ]]; then
  printf '%s\n' "$CURRENT_CHUNK" > "$TMPDIR/chunk_$(printf '%04d' $CHUNK_NUM)"
  ((CHUNK_NUM++))
fi

if [[ $CHUNK_NUM -eq 0 ]]; then
  # Not a git diff format — try splitting on "---" lines (plain unified diff)
  echo "$DIFF"
  exit 0
fi

# Generate a shuffled order using the seed
# Use awk with seeded random to create a permutation
ls "$TMPDIR"/chunk_* 2>/dev/null | awk -v seed="$SEED" '
  BEGIN { srand(seed) }
  { print rand() "\t" $0 }
' | sort -k1,1n | cut -f2- | while IFS= read -r chunk_file; do
  cat "$chunk_file"
done
