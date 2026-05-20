#!/usr/bin/env bash
# 03-dry-run.sh — preview the codemod across the codebase WITHOUT writing files.
# Part of: codemod-react-pipeline  (outer loop, step 3 — the safety gate before any apply)
#
# Produces a findings report (how many files would change, which ones, sample diffs) and writes
# the dry-run sentinel that 05-run-batched.sh requires before it will touch files at scale.
#
# Usage:
#   bash 03-dry-run.sh <name>                  # dry-run over config.src_globs target dir
#   bash 03-dry-run.sh <name> --target <dir>   # restrict to a sub-tree (e.g. a sample)
#   bash 03-dry-run.sh <name> --sample <N>     # dry-run a random N-file sample (fast on huge repos)
#
# Exit: 0 = dry-run completed (sentinel written), 1 = error.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

NAME=""; TARGET=""; SAMPLE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) shift; TARGET="${1:-}"; [[ -n "$TARGET" ]] || die "--target needs a path" ;;
    --sample) shift; SAMPLE="${1:-0}"; [[ "$SAMPLE" =~ ^[0-9]+$ ]] || die "--sample needs a number" ;;
    -*) die "Unknown flag: $1" ;;
    *) [[ -z "$NAME" ]] && NAME="$1" || die "Unexpected argument: $1" ;;
  esac
  shift
done
[[ -n "$NAME" ]] || { echo "Usage: $0 <name> [--target <dir>] [--sample <N>]" >&2; exit 1; }

need_cmd git; need_cmd jq
require_codemod "$NAME"

LANGUAGE="$(config_get '.language' 'tsx')"
PROJ="$(codemod_proj_dir "$NAME")"
STATE="$(state_dir_for "$NAME")"
ROOT="$(target_root)"
CM="$(codemod_cli)"
REPORT="$STATE/findings.txt"
DIFF="$STATE/dry-run.diff"

# Resolve the transform/rule and the CLI invocation.
if [[ -f "$PROJ/transform.ts" ]]; then
  RUN=("jssg" "run" "$PROJ/transform.ts")
elif [[ -f "$PROJ/rule.yml" ]]; then
  # ast-grep rules are applied through the codemod workflow/ast-grep step; dry-run via ast-grep if present.
  RUN=()
else
  die "No transform.ts or rule.yml in ${PROJ#"$ROOT"/}. Scaffold first."
fi

# --- Build the dry-run diff -------------------------------------------------
log_step "Dry-running '$NAME' (no files will be modified)"
require_clean_git   # so the diff we capture is purely the codemod's doing

cleanup() { :; }
trap cleanup EXIT

if [[ ${#RUN[@]} -gt 0 ]]; then
  # JSSG path: --dry-run prints would-be changes; we also derive a real diff on a temp checkout
  # so we can count files reliably across CLI versions.
  TARGET_DIR="${TARGET:-$ROOT}"
  if [[ "$SAMPLE" -gt 0 ]]; then
    log_info "Sampling $SAMPLE files for a fast preview"
    mapfile -t FILES < <(list_candidates | shuf | head -n "$SAMPLE")
    [[ ${#FILES[@]} -gt 0 ]] || die "No candidate files to sample. Check config.src_globs."
    # Apply for real, capture diff, then revert — bounded to the sample only.
    # shellcheck disable=SC2086
    $CM "${RUN[@]}" "${FILES[@]/#/$ROOT/}" --language "$LANGUAGE" >/dev/null 2>&1 || true
  else
    # Try the native --dry-run first (no writes); fall back to apply+diff+revert if unsupported.
    # shellcheck disable=SC2086
    if $CM "${RUN[@]}" "$TARGET_DIR" --language "$LANGUAGE" --dry-run > "$STATE/dry-run.raw" 2>&1; then
      log_info "Captured native --dry-run output ($STATE/dry-run.raw)"
    fi
    # Apply for real to compute an exact diff, then revert everything.
    # shellcheck disable=SC2086
    $CM "${RUN[@]}" "$TARGET_DIR" --language "$LANGUAGE" >/dev/null 2>&1 || true
  fi
else
  log_warn "Declarative rule: previewing matches via ast-grep (install ast-grep for richer output)."
  command -v ast-grep >/dev/null 2>&1 \
    && ast-grep scan --rule "$PROJ/rule.yml" "$ROOT" > "$STATE/dry-run.raw" 2>&1 || true
  # Apply rule for real to diff, then revert.
  command -v ast-grep >/dev/null 2>&1 \
    && ast-grep scan --rule "$PROJ/rule.yml" --update-all "$ROOT" >/dev/null 2>&1 || true
fi

# --- Capture findings, then revert ALL changes -----------------------------
git -C "$ROOT" --no-pager diff > "$DIFF" || true
mapfile -t CHANGED < <(git -C "$ROOT" diff --name-only --diff-filter=ACMR || true)
N_CHANGED=${#CHANGED[@]}

log_step "Reverting dry-run edits (working tree returns to clean)"
git -C "$ROOT" checkout -- . 2>/dev/null || true
git -C "$ROOT" clean -fd -- "$(config_get '.state_dir' '.codemod-pipeline')" >/dev/null 2>&1 || true

# --- Write findings report -------------------------------------------------
{
  echo "# Dry-run findings: $NAME"
  echo "Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  echo "Files that WOULD change: $N_CHANGED"
  echo "Diff:    ${DIFF#"$ROOT"/}"
  echo ""
  echo "## Affected files"
  printf '%s\n' "${CHANGED[@]:-}(none)"
  echo ""
  echo "## Sample diff (first 120 lines)"
  head -n 120 "$DIFF" 2>/dev/null || echo "(empty)"
} > "$REPORT"

echo "" >&2
if [[ "$N_CHANGED" -eq 0 ]]; then
  log_warn "Dry-run produced 0 changes. The transform may not be matching — revisit step 02."
  log_warn "Sentinel NOT written; fix the transform before applying."
  exit 1
fi

# Sentinel records what was previewed so the apply step can sanity-check scope.
cat > "$(dry_run_sentinel "$NAME")" <<EOF
codemod=$NAME
dry_run_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
files_changed=$N_CHANGED
sample=${SAMPLE}
target=${TARGET:-<all>}
EOF

log_ok "Dry-run complete: $N_CHANGED file(s) would change."
log_ok "Findings: ${REPORT#"$ROOT"/}"
echo "" >&2
echo "Inspect the findings, then validate them:" >&2
echo "  less ${REPORT#"$ROOT"/}" >&2
echo "  bash $SCRIPT_DIR/04-validate-findings.sh $NAME" >&2
