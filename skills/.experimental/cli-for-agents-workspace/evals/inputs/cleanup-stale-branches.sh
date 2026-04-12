#!/usr/bin/env bash
#
# cleanup-stale-branches — delete local git branches that have been merged
# into main more than 30 days ago. Used by the ops team when cleaning up
# forgotten branches on shared dev servers.
#
# Current problem: our AI agents on the ops team can't use this safely because
# there's no way to preview what would be deleted, and no way to skip the
# confirmation prompt.

set -e

MAIN_BRANCH="main"
STALE_DAYS=30

echo "Fetching latest from origin..."
git fetch --prune origin

echo "Finding merged branches older than ${STALE_DAYS} days..."
branches=$(git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads/ | \
  awk -v cutoff="$(date -v-${STALE_DAYS}d +%s)" '$2 < cutoff {print $1}')

to_delete=()
for branch in $branches; do
  if [ "$branch" = "$MAIN_BRANCH" ]; then
    continue
  fi
  if git merge-base --is-ancestor "$branch" "$MAIN_BRANCH"; then
    to_delete+=("$branch")
  fi
done

if [ ${#to_delete[@]} -eq 0 ]; then
  echo "No stale branches to delete."
  exit 0
fi

echo "Found ${#to_delete[@]} stale branches:"
for b in "${to_delete[@]}"; do
  echo "  - $b"
done

read -p "Delete all ${#to_delete[@]} branches? (yes/no): " answer
if [ "$answer" != "yes" ]; then
  echo "Cancelled."
  exit 1
fi

for b in "${to_delete[@]}"; do
  git branch -D "$b"
  echo "Deleted $b"
done

echo "Done."
