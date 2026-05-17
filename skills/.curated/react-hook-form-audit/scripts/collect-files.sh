#!/usr/bin/env bash
# collect-files.sh — Collect candidate files that import react-hook-form.
# Part of: react-hook-form-audit
# Output: JSON array of relative paths on stdout

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <project-root> <config-file>" >&2
  exit 2
fi
PROJECT_ROOT="$1"
CONFIG_FILE="$2"

# Build ripgrep args from include/exclude globs.
RG_ARGS=(--files-with-matches --glob '!**/node_modules/**')
while IFS= read -r glob; do
  RG_ARGS+=(--glob "$glob")
done < <(jq -r '.include_globs[]?' "$CONFIG_FILE")
while IFS= read -r glob; do
  RG_ARGS+=(--glob "!$glob")
done < <(jq -r '.exclude_globs[]?' "$CONFIG_FILE")

# Match `from 'react-hook-form'` (handles single/double quotes and subpath imports)
PATTERN="from ['\"]react-hook-form(/|['\"])"

cd "$PROJECT_ROOT"
# rg exits 1 when no matches — convert to empty list so the pipeline continues.
# Pass `.` explicitly so rg searches the directory and never tries to read from stdin
# (which would hang inside command substitution).
MATCHES="$(rg "${RG_ARGS[@]}" "$PATTERN" . 2>/dev/null || true)"
# Strip leading ./ that rg prepends when searching `.` explicitly.
MATCHES="$(printf '%s' "$MATCHES" | sed 's|^\./||')"

if [[ -z "$MATCHES" ]]; then
  echo "[]"
  exit 0
fi

# Emit JSON array of relative paths.
printf '%s\n' "$MATCHES" | jq -R . | jq -s .
