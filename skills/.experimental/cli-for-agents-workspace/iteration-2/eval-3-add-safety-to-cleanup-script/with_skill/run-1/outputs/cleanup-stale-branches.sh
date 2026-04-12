#!/usr/bin/env bash
#
# cleanup-stale-branches — delete local git branches that have been merged
# into main more than 30 days ago. Used by the ops team when cleaning up
# forgotten branches on shared dev servers.
#
# Agent-friendly: supports --dry-run for preview, --yes / --no-input for
# headless invocation, and uses sysexits.h exit codes so agents can branch
# on the failure class without parsing stderr.

set -euo pipefail

# sysexits.h exit codes. Agents branch on these, so do not renumber.
readonly EX_OK=0
readonly EX_FAILURE=1
readonly EX_USAGE=2
readonly EX_TEMPFAIL=75        # transient failure, retry-friendly

readonly MAIN_BRANCH="main"
readonly STALE_DAYS=30
readonly PROG="${0##*/}"

DRY_RUN=0
ASSUME_YES=0
NO_INPUT=0

# Env-var fallback for --no-input (parity with --yes for headless callers).
if [[ "${CLEANUP_NO_INPUT:-}" == "1" ]]; then
  NO_INPUT=1
fi

usage() {
  cat <<EOF
Usage: $PROG [OPTIONS]

Delete local branches merged into '$MAIN_BRANCH' and older than $STALE_DAYS days.

Options:
  -n, --dry-run     Show which branches would be deleted, without deleting them.
                    Prints one branch name per line on stdout.
  -y, --yes         Skip the interactive confirmation prompt (required when
                    running non-interactively without --dry-run).
      --no-input    Force non-interactive mode. Equivalent to --yes for this
                    script. Also honored via the CLEANUP_NO_INPUT=1 env var.
  -h, --help        Show this help and exit.

Exit codes:
  0   Success (including "nothing to delete").
  1   Generic failure (e.g. a 'git branch -D' call failed).
  2   Usage error (unknown flag, or non-TTY invocation without --yes).
  75  Transient failure (git fetch failed). Safe to retry with backoff.

Examples:
  # Human, interactive:
  $PROG

  # Agent, preview only:
  $PROG --dry-run

  # Agent, actually delete without prompting:
  $PROG --yes

  # Agent, via env var (e.g. CI):
  CLEANUP_NO_INPUT=1 $PROG
EOF
}

log() {
  # Diagnostics go to stderr so stdout stays clean for agents parsing dry-run.
  echo "$@" >&2
}

# --- Parse flags --------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -y|--yes)
      ASSUME_YES=1
      shift
      ;;
    --no-input)
      NO_INPUT=1
      shift
      ;;
    -h|--help)
      usage
      exit "$EX_OK"
      ;;
    --)
      shift
      break
      ;;
    -*)
      log "Error: unknown flag '$1'"
      log "  Run '$PROG --help' for usage."
      exit "$EX_USAGE"
      ;;
    *)
      log "Error: unexpected positional argument '$1'"
      log "  Run '$PROG --help' for usage."
      exit "$EX_USAGE"
      ;;
  esac
done

# --no-input implies --yes for a script whose only interaction is a confirm.
if (( NO_INPUT )); then
  ASSUME_YES=1
fi

# --- Fetch --------------------------------------------------------------------

log "Fetching latest from origin..."
if ! git fetch --prune origin >&2; then
  log "Error: 'git fetch --prune origin' failed (network/upstream)."
  log "  Retry in a few seconds, or check your network/VPN."
  exit "$EX_TEMPFAIL"   # agent: retry with backoff
fi

# --- Discover stale branches --------------------------------------------------

log "Finding merged branches older than ${STALE_DAYS} days..."

# Portable-ish cutoff: try BSD date first (macOS), fall back to GNU date.
if cutoff="$(date -v-${STALE_DAYS}d +%s 2>/dev/null)"; then
  :
elif cutoff="$(date -d "${STALE_DAYS} days ago" +%s 2>/dev/null)"; then
  :
else
  log "Error: could not compute cutoff date with 'date'."
  log "  Requires BSD date (macOS) or GNU date (Linux)."
  exit "$EX_FAILURE"
fi

mapfile -t candidates < <(
  git for-each-ref \
    --format='%(refname:short) %(committerdate:unix)' \
    refs/heads/ \
    | awk -v cutoff="$cutoff" '$2 < cutoff {print $1}'
)

to_delete=()
for branch in "${candidates[@]}"; do
  [[ -z "$branch" ]] && continue
  if [[ "$branch" == "$MAIN_BRANCH" ]]; then
    continue
  fi
  if git merge-base --is-ancestor "$branch" "$MAIN_BRANCH" 2>/dev/null; then
    to_delete+=("$branch")
  fi
done

if [[ ${#to_delete[@]} -eq 0 ]]; then
  log "No stale branches to delete."
  exit "$EX_OK"
fi

# --- Dry-run short-circuit ----------------------------------------------------

if (( DRY_RUN )); then
  log "Would delete ${#to_delete[@]} stale branches:"
  # Machine-readable: one branch per line on stdout so agents can pipe/grep.
  printf '%s\n' "${to_delete[@]}"
  exit "$EX_OK"
fi

# --- Confirm ------------------------------------------------------------------

log "Found ${#to_delete[@]} stale branches:"
for b in "${to_delete[@]}"; do
  log "  - $b"
done

if (( ! ASSUME_YES )); then
  # Refuse to hang on a missing TTY. Agents almost always hit this branch
  # when they forget --yes; fail fast with a copy-pasteable fix.
  if [[ ! -t 0 ]]; then
    log "Error: refusing to prompt for confirmation: stdin is not a TTY."
    log "  Re-run non-interactively with one of:"
    log "    $PROG --yes"
    log "    $PROG --no-input"
    log "    CLEANUP_NO_INPUT=1 $PROG"
    log "  Or preview first with:"
    log "    $PROG --dry-run"
    exit "$EX_USAGE"
  fi

  read -r -p "Delete all ${#to_delete[@]} branches? (yes/no): " answer
  if [[ "$answer" != "yes" ]]; then
    log "Cancelled."
    exit "$EX_OK"
  fi
fi

# --- Delete -------------------------------------------------------------------

rc="$EX_OK"
for b in "${to_delete[@]}"; do
  if git branch -D "$b" >&2; then
    log "Deleted $b"
  else
    log "Error: failed to delete '$b'"
    rc="$EX_FAILURE"
  fi
done

if [[ "$rc" != "$EX_OK" ]]; then
  log "Done with errors."
  exit "$rc"
fi

log "Done."
exit "$EX_OK"
