#!/usr/bin/env bash
#
# cleanup-stale-branches — delete local git branches that have been merged
# into main more than 30 days ago. Used by the ops team when cleaning up
# forgotten branches on shared dev servers.
#
# Usage:
#   cleanup-stale-branches.sh [OPTIONS]
#
# Options:
#   -n, --dry-run    Preview which branches would be deleted without deleting
#                    anything. Exits with code 0. Safe to run in automation.
#   -y, --yes        Skip the interactive confirmation prompt and proceed with
#                    deletion. Intended for automation (CI, AI agents, etc).
#   -h, --help       Show this help message and exit.
#
# Exit codes:
#   0  Success (branches deleted, no branches to delete, or dry-run completed)
#   1  Cancelled by user at confirmation prompt
#   2  Invalid arguments
#
# Examples:
#   # Interactive (humans) — preserves original behavior
#   ./cleanup-stale-branches.sh
#
#   # Preview only — safe for AI agents to inspect impact
#   ./cleanup-stale-branches.sh --dry-run
#
#   # Non-interactive deletion — for automation
#   ./cleanup-stale-branches.sh --yes
#
#   # Preview then delete (recommended agent workflow)
#   ./cleanup-stale-branches.sh --dry-run
#   ./cleanup-stale-branches.sh --yes

set -e

MAIN_BRANCH="main"
STALE_DAYS=30

DRY_RUN=0
ASSUME_YES=0

usage() {
  sed -n '2,34p' "$0" | sed 's/^# \{0,1\}//'
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -y|--yes)
      ASSUME_YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: unknown option '$1'" >&2
      echo "Run '$0 --help' for usage." >&2
      exit 2
      ;;
    *)
      echo "Error: unexpected argument '$1'" >&2
      echo "Run '$0 --help' for usage." >&2
      exit 2
      ;;
  esac
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] No branches will actually be deleted."
fi

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

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] Would delete ${#to_delete[@]} branches. No changes made."
  exit 0
fi

if [ "$ASSUME_YES" -eq 1 ]; then
  echo "Proceeding with deletion (--yes specified)..."
else
  read -p "Delete all ${#to_delete[@]} branches? (yes/no): " answer
  if [ "$answer" != "yes" ]; then
    echo "Cancelled."
    exit 1
  fi
fi

for b in "${to_delete[@]}"; do
  git branch -D "$b"
  echo "Deleted $b"
done

echo "Done."
