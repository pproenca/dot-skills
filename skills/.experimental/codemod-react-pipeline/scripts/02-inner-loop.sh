#!/usr/bin/env bash
# 02-inner-loop.sh — the tight feedback loop: fixture tests + a single-file trial run.
# Part of: codemod-react-pipeline  (inner loop, step 2)
#
# Run this repeatedly while writing the transform. It does NOT touch the wider codebase.
#
# Usage:
#   bash 02-inner-loop.sh <name>                 # run fixture tests once
#   bash 02-inner-loop.sh <name> --watch         # re-run fixture tests on change
#   bash 02-inner-loop.sh <name> --file <path>   # trial-run on ONE real file, show diff, revert
#   bash 02-inner-loop.sh <name> -u              # update fixture snapshots (intentional)
#
# Exit: 0 = tests pass / trial done, 1 = error or failing tests.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

NAME=""; WATCH=0; UPDATE=0; ONE_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --watch) WATCH=1 ;;
    -u|--update-snapshots) UPDATE=1 ;;
    --file) shift; ONE_FILE="${1:-}"; [[ -n "$ONE_FILE" ]] || die "--file needs a path" ;;
    -*) die "Unknown flag: $1" ;;
    *) [[ -z "$NAME" ]] && NAME="$1" || die "Unexpected argument: $1" ;;
  esac
  shift
done
[[ -n "$NAME" ]] || { echo "Usage: $0 <name> [--watch] [--file <path>] [-u]" >&2; exit 1; }

need_cmd git
need_cmd jq
require_codemod "$NAME"

LANGUAGE="$(config_get '.language' 'tsx')"
PROJ="$(codemod_proj_dir "$NAME")"
CM="$(codemod_cli)"

# A declarative rule (rule.yml) is run via ast-grep, not jssg test.
if [[ -f "$PROJ/rule.yml" && ! -f "$PROJ/transform.ts" ]]; then
  log_step "Declarative rule detected — validating with ast-grep"
  if command -v ast-grep >/dev/null 2>&1; then
    ast-grep scan --rule "$PROJ/rule.yml" "$(target_root)" || true
    log_info "Review matches above. ast-grep has no fixture runner; rely on dry-run (step 03) to confirm."
  else
    log_warn "ast-grep not installed. Run dry-run (03) to preview rule matches via the codemod CLI."
  fi
  exit 0
fi

TRANSFORM="$PROJ/transform.ts"
[[ -f "$TRANSFORM" ]] || die "No transform.ts in ${PROJ#"$(target_root)"/}. Scaffold first (01-scaffold.sh $NAME)."

# --- Single-file trial run (no commit, auto-revert) ------------------------
if [[ -n "$ONE_FILE" ]]; then
  [[ -f "$ONE_FILE" ]] || die "File not found: $ONE_FILE"
  require_clean_git
  log_step "Trial run on a single file: $ONE_FILE"
  # shellcheck disable=SC2086
  $CM jssg run "$TRANSFORM" "$ONE_FILE" --language "$LANGUAGE"
  echo "" >&2
  if git -C "$(target_root)" diff --quiet -- "$ONE_FILE"; then
    log_warn "No change produced on this file. Is the pattern matching? Check the AST playground."
  else
    log_step "Diff:"
    git -C "$(target_root)" --no-pager diff -- "$ONE_FILE" >&2 || true
    log_step "Reverting trial change (inner loop never keeps edits)"
    git -C "$(target_root)" checkout -- "$ONE_FILE"
    log_ok "Reverted. Promote to a fixture if this case matters: tests/<case>/{input,expected}.*"
  fi
  exit 0
fi

# --- Fixture tests ---------------------------------------------------------
ARGS=(jssg test "$TRANSFORM" --language "$LANGUAGE")
[[ $UPDATE -eq 1 ]] && ARGS+=(--update-snapshots)
[[ $WATCH  -eq 1 ]] && ARGS+=(--watch)

if [[ $UPDATE -eq 1 ]]; then
  log_warn "Updating fixture snapshots — only do this when the new output is intentional."
fi
log_step "Running fixture tests for '$NAME'"
# shellcheck disable=SC2086
exec $CM "${ARGS[@]}"
