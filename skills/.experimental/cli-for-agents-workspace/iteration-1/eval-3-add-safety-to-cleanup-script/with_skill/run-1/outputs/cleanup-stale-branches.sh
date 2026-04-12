#!/usr/bin/env bash
#
# cleanup-stale-branches — delete local git branches that have been merged
# into main more than N days ago. Used by the ops team when cleaning up
# forgotten branches on shared dev servers.
#
# Safe for humans AND agents:
#   - Default (human): lists stale branches and asks "yes/no" before deleting
#   - --dry-run:       prints what WOULD be deleted, deletes nothing
#   - --yes:           skips confirmation and deletes (for CI/agents)
#   - --no-input:      refuses to prompt; fails fast if --yes is missing
#   - --json:          emits machine-readable output for scripting
#
# Exit codes:
#   0  success (including "nothing to clean up" and dry-run)
#   1  runtime failure (git command failed, partial deletion, etc.)
#   2  usage error (bad flag, missing --yes in non-interactive mode)

set -euo pipefail

# ----------------------------------------------------------------------------
# Defaults (overridable by env vars, then flags)
# ----------------------------------------------------------------------------
MAIN_BRANCH="${CLEANUP_MAIN_BRANCH:-main}"
STALE_DAYS="${CLEANUP_STALE_DAYS:-30}"

DRY_RUN=0
ASSUME_YES=0
JSON_OUTPUT=0
VERBOSE=0
QUIET=0

# Normalize CLEANUP_NO_INPUT: any non-empty, non-"0", non-"false" value counts as "on"
NO_INPUT=0
case "${CLEANUP_NO_INPUT:-}" in
  ""|0|false|FALSE|no|NO) NO_INPUT=0 ;;
  *) NO_INPUT=1 ;;
esac

PROG="$(basename "$0")"

# ----------------------------------------------------------------------------
# Help text  (help-examples-in-help, help-flag-summary, help-suggest-next-steps)
# ----------------------------------------------------------------------------
print_help() {
  cat <<EOF
Usage: ${PROG} [OPTIONS]

Delete local git branches that have been merged into ${MAIN_BRANCH} and whose
last commit is older than ${STALE_DAYS} days. The main branch is never deleted.

Safety:
  By default the command lists the branches it would delete and asks for
  confirmation ("yes/no") before touching anything. Use --dry-run to preview
  without the prompt, or --yes to skip the prompt (for agents and CI).

Options:
  -n, --dry-run            show what would be deleted; delete nothing
  -y, --yes                skip confirmation and delete (required in non-interactive mode)
      --no-input           fail fast instead of prompting (implies a refusal to prompt;
                           combine with --yes to actually delete)
      --json               emit machine-readable JSON output instead of plain text
  -m, --main-branch NAME   branch to compare against (default: ${MAIN_BRANCH};
                           env: CLEANUP_MAIN_BRANCH)
  -d, --stale-days N       only delete branches older than N days (default: ${STALE_DAYS};
                           env: CLEANUP_STALE_DAYS)
  -v, --verbose            print extra diagnostics to stderr
  -q, --quiet              suppress progress messages (errors still go to stderr)
  -h, --help               show this help and exit

Environment variables:
  CLEANUP_MAIN_BRANCH      default value for --main-branch
  CLEANUP_STALE_DAYS       default value for --stale-days
  CLEANUP_NO_INPUT         set to 1 to imply --no-input (e.g. in CI)
  NO_COLOR                 any non-empty value disables ANSI color output

Examples:
  # Preview what would be deleted (safe, touches nothing)
  ${PROG} --dry-run

  # Preview as JSON so an agent can parse the branch list
  ${PROG} --dry-run --json

  # Delete without prompting (agent / CI path)
  ${PROG} --yes

  # Delete, but fail loudly if anything would try to prompt
  ${PROG} --yes --no-input

  # Compare against a non-default main branch, 14-day cutoff
  ${PROG} --main-branch master --stale-days 14 --dry-run

  # Same, via environment variables
  CLEANUP_MAIN_BRANCH=master CLEANUP_STALE_DAYS=14 ${PROG} --dry-run

Next steps:
  ${PROG} --dry-run            # always run this first on a new repo
  ${PROG} --dry-run --json     # to feed the list into another tool
  git reflog                   # recover a branch deleted by mistake
EOF
}

# ----------------------------------------------------------------------------
# Logging helpers  (err-stderr-not-stdout, output-respect-no-color)
# ----------------------------------------------------------------------------
# All diagnostic / progress output goes to stderr so that stdout stays a
# clean data stream (plain text list or --json) for pipelines.

log_info() {
  (( QUIET )) && return 0
  printf '%s\n' "$*" >&2
}

log_verbose() {
  (( VERBOSE )) || return 0
  printf '[verbose] %s\n' "$*" >&2
}

log_error() {
  printf 'Error: %s\n' "$*" >&2
}

# ----------------------------------------------------------------------------
# Argument parsing  (struct-flag-order-independent, struct-standard-flag-names,
#                    input-flags-over-positional, err-actionable-fix,
#                    err-include-example-invocation, err-non-zero-exit-codes)
# ----------------------------------------------------------------------------
# Zero args is allowed and preserves the original human workflow: list, then
# ask for confirmation. Help is available via -h / --help.

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -y|--yes|--force)
      ASSUME_YES=1
      shift
      ;;
    --no-input)
      NO_INPUT=1
      shift
      ;;
    --json)
      JSON_OUTPUT=1
      shift
      ;;
    -m|--main-branch)
      if [[ $# -lt 2 ]]; then
        log_error "--main-branch requires a value."
        printf '  %s --main-branch main --dry-run\n' "$PROG" >&2
        exit 2
      fi
      MAIN_BRANCH="$2"
      shift 2
      ;;
    --main-branch=*)
      MAIN_BRANCH="${1#*=}"
      shift
      ;;
    -d|--stale-days)
      if [[ $# -lt 2 ]]; then
        log_error "--stale-days requires a value."
        printf '  %s --stale-days 30 --dry-run\n' "$PROG" >&2
        exit 2
      fi
      STALE_DAYS="$2"
      shift 2
      ;;
    --stale-days=*)
      STALE_DAYS="${1#*=}"
      shift
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -q|--quiet)
      QUIET=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      log_error "unknown flag '$1'."
      printf '  %s --help\n' "$PROG" >&2
      printf '  %s --dry-run\n' "$PROG" >&2
      exit 2
      ;;
    *)
      log_error "unexpected positional argument '$1'. This command takes no positional arguments."
      printf '  %s --help\n' "$PROG" >&2
      exit 2
      ;;
  esac
done

# ----------------------------------------------------------------------------
# Validate flag values  (err-exit-fast-on-missing-required, err-actionable-fix)
# ----------------------------------------------------------------------------
if ! [[ "$STALE_DAYS" =~ ^[0-9]+$ ]] || [[ "$STALE_DAYS" -lt 1 ]]; then
  log_error "--stale-days must be a positive integer, got '${STALE_DAYS}'."
  printf '  %s --stale-days 30 --dry-run\n' "$PROG" >&2
  exit 2
fi

if [[ -z "$MAIN_BRANCH" ]]; then
  log_error "--main-branch must not be empty."
  printf '  %s --main-branch main --dry-run\n' "$PROG" >&2
  exit 2
fi

# ----------------------------------------------------------------------------
# Work out whether we are effectively non-interactive
# (interact-detect-tty, interact-no-input-flag, safe-no-prompts-with-no-input)
# ----------------------------------------------------------------------------
IS_TTY=0
if [[ -t 0 ]]; then
  IS_TTY=1
fi

# Non-interactive = explicit --no-input OR stdin is not a TTY
NON_INTERACTIVE=0
if [[ "$NO_INPUT" -eq 1 ]] || [[ "$IS_TTY" -eq 0 ]]; then
  NON_INTERACTIVE=1
fi

log_verbose "dry_run=${DRY_RUN} assume_yes=${ASSUME_YES} no_input=${NO_INPUT} is_tty=${IS_TTY} non_interactive=${NON_INTERACTIVE} json=${JSON_OUTPUT}"
log_verbose "main_branch='${MAIN_BRANCH}' stale_days=${STALE_DAYS}"

# ----------------------------------------------------------------------------
# Sanity-check the git environment  (err-actionable-fix)
# ----------------------------------------------------------------------------
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log_error "not inside a git repository."
  printf '  cd <your-repo> && %s --dry-run\n' "$PROG" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${MAIN_BRANCH}"; then
  log_error "main branch '${MAIN_BRANCH}' does not exist locally."
  printf '  %s --main-branch master --dry-run\n' "$PROG" >&2
  printf '  git branch --list           # to see available branches\n' >&2
  exit 1
fi

# ----------------------------------------------------------------------------
# Compute stale cutoff in a portable way (BSD date vs GNU date)
# ----------------------------------------------------------------------------
if date -v-1d >/dev/null 2>&1; then
  CUTOFF="$(date -v-"${STALE_DAYS}"d +%s)"
else
  CUTOFF="$(date -d "${STALE_DAYS} days ago" +%s)"
fi
log_verbose "cutoff unix timestamp: ${CUTOFF}"

# ----------------------------------------------------------------------------
# Fetch latest state
# ----------------------------------------------------------------------------
log_info "Fetching latest from origin..."
if ! git fetch --prune origin >&2; then
  log_error "git fetch failed."
  printf '  check network / remote access, then rerun: %s --dry-run\n' "$PROG" >&2
  exit 1
fi

# ----------------------------------------------------------------------------
# Find merged branches older than the cutoff
# ----------------------------------------------------------------------------
log_info "Finding merged branches older than ${STALE_DAYS} days (vs ${MAIN_BRANCH})..."

branches=$(git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads/ \
  | awk -v cutoff="$CUTOFF" '$2 < cutoff {print $1}')

to_delete=()
for branch in $branches; do
  if [[ "$branch" == "$MAIN_BRANCH" ]]; then
    log_verbose "skip ${branch}: is the main branch"
    continue
  fi
  if git merge-base --is-ancestor "$branch" "$MAIN_BRANCH" 2>/dev/null; then
    to_delete+=("$branch")
  else
    log_verbose "skip ${branch}: not fully merged into ${MAIN_BRANCH}"
  fi
done

# ----------------------------------------------------------------------------
# Helper: emit the final result.
# (output-json-flag, output-one-record-per-line, output-machine-ids-on-success,
#  idem-stable-output-on-skip)
# stdout is ALWAYS the machine-facing channel (plain text = one branch per
# line; JSON = a single structured object). Anything else goes to stderr.
# ----------------------------------------------------------------------------
emit_result() {
  local action="$1"   # one of: would-delete, deleted, noop, cancelled
  shift
  local branches=("$@")
  local count="${#branches[@]}"

  if (( JSON_OUTPUT )); then
    local joined=""
    if (( count > 0 )); then
      joined=$(printf '"%s",' "${branches[@]}")
      joined="${joined%,}"
    fi
    printf '{"action":"%s","main_branch":"%s","stale_days":%s,"count":%s,"branches":[%s]}\n' \
      "$action" "$MAIN_BRANCH" "$STALE_DAYS" "$count" "$joined"
  else
    if (( count > 0 )); then
      printf '%s\n' "${branches[@]}"
    fi
  fi
}

# ----------------------------------------------------------------------------
# Nothing to do (safe-idempotent-cleanup, idem-retry-safe)
# ----------------------------------------------------------------------------
if [[ ${#to_delete[@]} -eq 0 ]]; then
  log_info "No stale branches to delete."
  emit_result "noop"
  exit 0
fi

# ----------------------------------------------------------------------------
# Preview the plan on stderr so stdout stays clean (still prints on dry-run)
# ----------------------------------------------------------------------------
log_info "Found ${#to_delete[@]} stale branches:"
for b in "${to_delete[@]}"; do
  log_info "  - $b"
done

# ----------------------------------------------------------------------------
# --dry-run: never deletes, always exits 0  (safe-dry-run-flag)
# ----------------------------------------------------------------------------
if (( DRY_RUN )); then
  log_info "Dry run: no branches were deleted."
  log_info "Rerun with --yes to actually delete: ${PROG} --yes"
  emit_result "would-delete" "${to_delete[@]}"
  exit 0
fi

# ----------------------------------------------------------------------------
# Confirmation gate  (safe-force-bypass-flag, safe-no-prompts-with-no-input,
#                     interact-detect-tty, input-no-prompt-fallback)
# ----------------------------------------------------------------------------
if (( ASSUME_YES == 0 )); then
  if (( NON_INTERACTIVE )); then
    log_error "refusing to delete ${#to_delete[@]} branches without --yes in non-interactive mode."
    printf '  %s --yes            # delete without prompting\n' "$PROG" >&2
    printf '  %s --dry-run        # preview without deleting\n' "$PROG" >&2
    printf '  %s --dry-run --json # preview as JSON\n' "$PROG" >&2
    exit 2
  fi

  # Interactive path: ask a human. Preserved from the original script so
  # existing human muscle memory keeps working.
  read -r -p "Delete all ${#to_delete[@]} branches? (yes/no): " answer
  if [[ "$answer" != "yes" ]]; then
    log_info "Cancelled."
    emit_result "cancelled" "${to_delete[@]}"
    exit 1
  fi
fi

# ----------------------------------------------------------------------------
# Perform deletions  (safe-idempotent-cleanup, err-non-zero-exit-codes)
# ----------------------------------------------------------------------------
deleted=()
failed=()

for b in "${to_delete[@]}"; do
  if ! git show-ref --verify --quiet "refs/heads/${b}"; then
    # Already gone — treat as success for idempotency (safe-idempotent-cleanup)
    log_info "Already absent: $b"
    deleted+=("$b")
    continue
  fi
  if git branch -D "$b" >&2; then
    log_info "Deleted $b"
    deleted+=("$b")
  else
    log_error "failed to delete $b"
    failed+=("$b")
  fi
done

# ----------------------------------------------------------------------------
# Final report  (output-machine-ids-on-success, help-suggest-next-steps)
# ----------------------------------------------------------------------------
if (( ${#failed[@]} > 0 )); then
  log_error "${#failed[@]} branch(es) could not be deleted:"
  for b in "${failed[@]}"; do
    log_error "  - $b"
  done
  printf '  %s --verbose --yes   # rerun with more diagnostics\n' "$PROG" >&2
  printf '  git reflog                # recover a branch deleted by mistake\n' >&2
  emit_result "deleted" "${deleted[@]}"
  exit 1
fi

log_info "Done. Deleted ${#deleted[@]} branch(es)."
log_info "Tip: run 'git reflog' to recover a branch deleted by mistake."
emit_result "deleted" "${deleted[@]}"
exit 0
