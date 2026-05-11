#!/usr/bin/env bash
# apply.sh — Apply jscodeshift codemods to files flagged in scan.json.
# Part of: nuqs-codemod-runner
#
# Refuses to run if:
#   - scan.json is missing or older than $scan_max_age_minutes (from config.json)
#   - working tree is dirty (override with --allow-dirty)
#   - scan.json's gitHead differs from current HEAD
#
# On success: writes last-run.json with the list of touched files (used by verify.sh for rollback).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_ROOT/config.json"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$SKILL_ROOT}"
SCAN_FILE="$DATA_DIR/scan.json"
LAST_RUN_FILE="$DATA_DIR/last-run.json"

ALLOW_DIRTY=0
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    --filter)      FILTER="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--filter <codemod-id>] [--allow-dirty]"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# --- Pre-flight ---
for tool in jq npx git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: '$tool' is not installed." >&2
    exit 1
  fi
done

if [[ ! -f "$SCAN_FILE" ]]; then
  echo "Error: $SCAN_FILE not found. Run 'scripts/scan.sh <repo>' first." >&2
  exit 1
fi

REPO_ROOT=$(jq -r '.meta.repoRoot' "$SCAN_FILE")
SCAN_HEAD=$(jq -r '.meta.gitHead' "$SCAN_FILE")
SCAN_AT=$(jq -r '.meta.scannedAt' "$SCAN_FILE")
MAX_AGE_MIN=$(jq -r '.scan_max_age_minutes' "$CONFIG_FILE")

cd "$REPO_ROOT"

CURRENT_HEAD=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
if [[ "$SCAN_HEAD" != "$CURRENT_HEAD" ]]; then
  echo "Error: scan.json was generated against git HEAD $SCAN_HEAD," >&2
  echo "but current HEAD is $CURRENT_HEAD. Re-run scan.sh." >&2
  exit 1
fi

# Staleness check (portable: use python for date math since `date -d` is GNU-only)
AGE_MIN=$(python3 -c "
import sys, datetime
scan = datetime.datetime.fromisoformat('$SCAN_AT'.replace('Z', '+00:00'))
now  = datetime.datetime.now(datetime.timezone.utc)
print(int((now - scan).total_seconds() // 60))
")
if (( AGE_MIN > MAX_AGE_MIN )); then
  echo "Error: scan.json is $AGE_MIN min old (max: $MAX_AGE_MIN). Re-run scan.sh." >&2
  exit 1
fi

# Dirty tree guard
if [[ $ALLOW_DIRTY -eq 0 ]] && ! git diff --quiet HEAD 2>/dev/null; then
  echo "Error: working tree is dirty. Commit or stash first, or pass --allow-dirty." >&2
  echo "See gotchas.md before using --allow-dirty." >&2
  exit 1
fi

# --- Collect target files per codemod ---
get_files_for() {
  local codemod="$1"
  jq -r --arg c "$codemod" '[.matches[] | select(.codemod == $c) | .path] | unique | .[]' "$SCAN_FILE"
}

mapfile -t CODEMODS < <(jq -r '[.matches[].codemod] | unique | .[]' "$SCAN_FILE")

if [[ -n "$FILTER" ]]; then
  # shellcheck disable=SC2076
  if [[ ! " ${CODEMODS[*]} " =~ " $FILTER " ]]; then
    echo "Error: --filter '$FILTER' has no matches in scan.json. Available: ${CODEMODS[*]}" >&2
    exit 1
  fi
  CODEMODS=("$FILTER")
fi

# --- Locate jscodeshift (npx will install if missing) ---
JSCODESHIFT="npx --yes jscodeshift@latest"

# --- Apply each transform ---
TOUCHED=()
for codemod in "${CODEMODS[@]}"; do
  TRANSFORM="$SKILL_ROOT/scripts/transforms/$codemod.js"
  if [[ ! -f "$TRANSFORM" ]]; then
    echo "Skipping '$codemod': no transform at $TRANSFORM" >&2
    continue
  fi

  mapfile -t FILES < <(get_files_for "$codemod")
  if [[ ${#FILES[@]} -eq 0 ]]; then
    continue
  fi

  echo
  echo "→ $codemod (${#FILES[@]} file(s))"

  # Make file paths absolute so jscodeshift can find them regardless of cwd
  ABS_FILES=()
  for f in "${FILES[@]}"; do ABS_FILES+=("$REPO_ROOT/$f"); done

  $JSCODESHIFT \
    --transform "$TRANSFORM" \
    --parser tsx \
    --extensions=ts,tsx,js,jsx \
    --no-babel \
    --print=false \
    --run-in-band \
    "${ABS_FILES[@]}"

  TOUCHED+=("${FILES[@]}")
done

# --- Record what was touched, for verify.sh rollback ---
TOUCHED_UNIQUE=$(printf "%s\n" "${TOUCHED[@]}" | sort -u | jq -R . | jq -s .)
jq -n --argjson files "$TOUCHED_UNIQUE" \
      --arg repo "$REPO_ROOT" \
      --arg head "$CURRENT_HEAD" \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{ repoRoot: $repo, gitHeadAtApply: $head, appliedAt: $ts, touchedFiles: $files }' \
      > "$LAST_RUN_FILE"

echo
echo "Applied. $(echo "$TOUCHED_UNIQUE" | jq 'length') file(s) modified."
echo "Run 'scripts/verify.sh' to typecheck + lint."
