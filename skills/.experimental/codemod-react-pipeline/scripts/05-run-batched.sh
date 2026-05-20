#!/usr/bin/env bash
# 05-run-batched.sh — apply the codemod at scale in resumable, verified, committed batches.
# Part of: codemod-react-pipeline  (outer loop, step 5 — the mass apply)
#
# For each batch of files: apply → run per-batch gates → git commit. Progress is recorded so a
# crash (or Ctrl-C) resumes from the next unfinished batch. Refuses to run without a prior
# successful dry-run (step 03). The PreToolUse hook enforces the same rule for ad-hoc commands.
#
# Usage:
#   bash 05-run-batched.sh <name>                 # process all remaining batches
#   bash 05-run-batched.sh <name> --resume        # same; explicit, prints prior progress
#   bash 05-run-batched.sh <name> --batch-size N   # override config.batch_size
#   bash 05-run-batched.sh <name> --dry            # show the batch plan, change nothing
#
# Exit: 0 = all batches done, 1 = a batch failed (stops; safe to fix and re-run), 2 = nothing to do.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

NAME=""; BATCH_SIZE=""; PLAN_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --resume) : ;;  # default behaviour; flag is for readability
    --batch-size) shift; BATCH_SIZE="${1:-}"; [[ "$BATCH_SIZE" =~ ^[0-9]+$ ]] || die "--batch-size needs a number" ;;
    --dry) PLAN_ONLY=1 ;;
    -*) die "Unknown flag: $1" ;;
    *) [[ -z "$NAME" ]] && NAME="$1" || die "Unexpected argument: $1" ;;
  esac
  shift
done
[[ -n "$NAME" ]] || { echo "Usage: $0 <name> [--resume] [--batch-size N] [--dry]" >&2; exit 1; }

need_cmd git; need_cmd jq
require_codemod "$NAME"
require_dry_run "$NAME"        # hard gate: no mass apply without an inspected dry-run

ROOT="$(target_root)"
STATE="$(state_dir_for "$NAME")"
[[ -z "$BATCH_SIZE" ]] && BATCH_SIZE="$(config_get '.batch_size' '500')"
PROGRESS="$STATE/progress.tsv"        # lines: <batch-index>\t<status>\t<commit-sha>
FILELIST="$STATE/files.txt"

# --- Build (or reuse) the work list ----------------------------------------
if [[ ! -f "$FILELIST" ]]; then
  log_step "Building file list from config.src_globs"
  list_candidates | sort > "$FILELIST"
fi
TOTAL=$(wc -l < "$FILELIST" | tr -d ' ')
[[ "$TOTAL" -gt 0 ]] || die "No files to process. Check config.src_globs."
N_BATCHES=$(( (TOTAL + BATCH_SIZE - 1) / BATCH_SIZE ))

log_step "$NAME: $TOTAL files, $BATCH_SIZE per batch → $N_BATCHES batch(es)"
touch "$PROGRESS"
done_count=$(grep -c $'\tok\t' "$PROGRESS" 2>/dev/null || true); done_count=${done_count:-0}
[[ "$done_count" -gt 0 ]] && log_info "Resuming — $done_count batch(es) already complete."

if [[ $PLAN_ONLY -eq 1 ]]; then
  log_ok "Plan only (no changes). $((N_BATCHES - done_count)) batch(es) remain."
  exit 0
fi

require_clean_git   # each batch commit must be isolated

# --- Per-batch gate runner (subset of step 04, scoped to the batch) --------
verify_batch() {
  local files_nul="$1" rc=0
  if gate_enabled typecheck; then
    local tc; tc="$(config_get '.typecheck_cmd' '')"
    [[ -n "$tc" ]] && { ( cd "$ROOT" && $tc ) >>"$STATE/batch.log" 2>&1 || rc=$?; }
  fi
  if [[ $rc -eq 0 ]] && gate_enabled lint; then
    local lc; lc="$(config_get '.lint_cmd' '')"
    [[ -n "$lc" ]] && { ( cd "$ROOT" && xargs -0 $lc < "$files_nul" ) >>"$STATE/batch.log" 2>&1 || rc=$?; }
  fi
  if [[ $rc -eq 0 ]] && gate_enabled tests; then
    local testc; testc="$(config_get '.test_cmd' '')"
    [[ -n "$testc" ]] && { ( cd "$ROOT" && xargs -0 $testc < "$files_nul" ) >>"$STATE/batch.log" 2>&1 || rc=$?; }
  fi
  return $rc
}

# --- Main batch loop -------------------------------------------------------
i=0
while [[ $i -lt $N_BATCHES ]]; do
  idx=$i; i=$((i + 1))
  # Skip already-completed batches (resumability).
  if grep -q "^${idx}"$'\tok\t' "$PROGRESS"; then continue; fi

  start=$(( idx * BATCH_SIZE + 1 ))
  mapfile -t BATCH < <(sed -n "${start},$((start + BATCH_SIZE - 1))p" "$FILELIST")
  [[ ${#BATCH[@]} -gt 0 ]] || continue
  log_step "Batch $((idx + 1))/$N_BATCHES — ${#BATCH[@]} files"

  : > "$STATE/batch.log"
  # Apply only to this batch's files.
  if ! ( cd "$ROOT" && codemod_apply "$NAME" "${BATCH[@]}" ) >>"$STATE/batch.log" 2>&1; then
    git -C "$ROOT" checkout -- . 2>/dev/null || true
    die "Batch $((idx + 1)) failed during apply. Log: ${STATE#"$ROOT"/}/batch.log. Fix and re-run to resume."
  fi

  # Nothing changed in this batch? Record and move on (idempotent / no matches here).
  if git -C "$ROOT" diff --quiet; then
    printf '%s\tok\t%s\n' "$idx" "(no-change)" >> "$PROGRESS"
    log_info "No matches in this batch."
    continue
  fi

  # Verify just this batch's affected files. Build the NUL list from an array (one NUL per file);
  # `printf '%s\0' "$(...)"` would emit a single blob with embedded newlines.
  mapfile -t BATCH_AFFECTED < <(git -C "$ROOT" diff --name-only --diff-filter=ACMR)
  printf '%s\0' "${BATCH_AFFECTED[@]}" > "$STATE/batch-affected.0"
  if ! verify_batch "$STATE/batch-affected.0"; then
    git -C "$ROOT" checkout -- . 2>/dev/null || true
    die "Batch $((idx + 1)) failed verification. Log: ${STATE#"$ROOT"/}/batch.log.
    The batch was reverted. Fix the transform/gate, then re-run to resume from this batch."
  fi

  # Checkpoint commit (local — workflow.yaml 'commit:' steps are cloud-only; see gotchas.md).
  git -C "$ROOT" add -A
  msg="refactor($NAME): batch $((idx + 1))/$N_BATCHES [codemod-react-pipeline]"
  git -C "$ROOT" commit -q -m "$msg"
  sha="$(git -C "$ROOT" rev-parse --short HEAD)"
  printf '%s\tok\t%s\n' "$idx" "$sha" >> "$PROGRESS"
  log_ok "Committed $sha"
done

echo "" >&2
log_ok "All $N_BATCHES batch(es) applied and committed."
echo "Run the final check:" >&2
echo "  bash $SCRIPT_DIR/verify.sh $NAME" >&2
echo "Roll back everything if needed (commits are tagged in the message):" >&2
echo "  git log --oneline --grep='\\[codemod-react-pipeline\\]'" >&2
