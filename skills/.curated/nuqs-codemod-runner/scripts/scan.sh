#!/usr/bin/env bash
# scan.sh — Scan a repository for pre-nuqs-2.5 patterns.
# Part of: nuqs-codemod-runner
#
# Output: scan.json (in $SKILL_DATA_DIR or pwd) — array of {codemod, path, line, snippet}.
# Exit codes: 0 = scan complete (any number of matches), 1 = scan error, 2 = no nuqs in package.json.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_ROOT/config.json"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$SKILL_ROOT}"
OUT_FILE="$DATA_DIR/scan.json"

# --- Input validation ---
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <repo-root>" >&2
  echo "Scans <repo-root> for pre-nuqs-2.5 patterns and writes scan.json." >&2
  exit 1
fi

REPO_ROOT="$1"
if [[ ! -d "$REPO_ROOT" ]]; then
  echo "Error: <repo-root> '$REPO_ROOT' is not a directory." >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "Error: ripgrep ('rg') is not installed. Install it (brew install ripgrep) and rerun." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is not installed. Install it (brew install jq) and rerun." >&2
  exit 1
fi

# --- Verify nuqs is a declared dep before doing anything ---
PKG_JSON="$REPO_ROOT/package.json"
if [[ ! -f "$PKG_JSON" ]] || ! jq -e '(.dependencies.nuqs // .devDependencies.nuqs) != null' "$PKG_JSON" >/dev/null 2>&1; then
  echo "No 'nuqs' dependency found in $PKG_JSON — nothing to migrate." >&2
  exit 2
fi

NUQS_VERSION=$(jq -r '.dependencies.nuqs // .devDependencies.nuqs // "unknown"' "$PKG_JSON")

# --- Build ripgrep --glob args from config ---
mapfile -t INCLUDE_GLOBS < <(jq -r '.include_globs[]' "$CONFIG_FILE")
mapfile -t EXCLUDE_GLOBS < <(jq -r '.exclude_globs[]' "$CONFIG_FILE")

RG_ARGS=(--json --multiline)
for g in "${INCLUDE_GLOBS[@]}"; do RG_ARGS+=(--glob "$g"); done
for g in "${EXCLUDE_GLOBS[@]}"; do RG_ARGS+=(--glob "!$g"); done

# --- Pattern catalog ---
# Keyed by codemod ID → regex (PCRE2). Multiline patterns enabled.
declare -A PATTERNS=(
  [throttle-ms]='\bthrottleMs\s*:\s*\d+'
  [react-router-unversioned]="from\\s*['\"]nuqs/adapters/react-router['\"]"
  [parser-builder-type]='\bParserBuilder\s*<'
  [unchecked-json-cast]='parseAsJson\s*(?:<[^>]+>)?\s*\(\s*(?:\)|\([a-zA-Z_$][\w$]*\)\s*=>\s*\w+\s+as\s+)'
  # The manual-debounce regex is intentionally loose — final classification happens in the transform.
  # Heuristic: a useState mirror near a useQueryState setter + a setTimeout call in the same file.
  [manual-debounce]='setTimeout\s*\(\s*\(\s*\)\s*=>\s*set[A-Z]\w+\s*\('
)

# --- Run ripgrep for each pattern, build JSON ---
TMP_JSON=$(mktemp)
trap 'rm -f "$TMP_JSON"' EXIT

echo '[]' > "$TMP_JSON"

for codemod in "${!PATTERNS[@]}"; do
  pattern="${PATTERNS[$codemod]}"

  # ripgrep --json emits one JSON object per match (type:"match"); we reshape with jq.
  rg "${RG_ARGS[@]}" -e "$pattern" "$REPO_ROOT" 2>/dev/null \
    | jq --arg codemod "$codemod" --arg root "$REPO_ROOT" -c '
        select(.type == "match")
        | {
            codemod: $codemod,
            path: (.data.path.text | sub("^" + $root + "/"; "")),
            line: .data.line_number,
            snippet: (.data.lines.text | rtrimstr("\n"))
          }
      ' \
    | jq -s --slurpfile prev "$TMP_JSON" '. as $new | ($prev[0] + $new)' > "${TMP_JSON}.next"
  mv "${TMP_JSON}.next" "$TMP_JSON"
done

# --- For manual-debounce, the regex over-matches: filter to files that ALSO contain a useQueryState call.
# We do this in jq by listing the candidate paths and reading them.
CANDIDATES=$(jq -r '.[] | select(.codemod == "manual-debounce") | .path' "$TMP_JSON" | sort -u)
KEEP_FILE=$(mktemp); trap 'rm -f "$KEEP_FILE"' EXIT
: > "$KEEP_FILE"
for rel_path in $CANDIDATES; do
  abs="$REPO_ROOT/$rel_path"
  if rg -q 'useQueryState\s*\(' "$abs" 2>/dev/null; then
    echo "$rel_path" >> "$KEEP_FILE"
  fi
done

jq --slurpfile keep "$KEEP_FILE" '
  map(
    if .codemod == "manual-debounce"
    then if ([.path] | inside($keep[0] // [])) then . else empty end
    else . end
  )
' "$TMP_JSON" > "${TMP_JSON}.filtered"
mv "${TMP_JSON}.filtered" "$TMP_JSON"

# --- Attach metadata for staleness check in apply.sh ---
GIT_HEAD=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "no-git")
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq --arg head "$GIT_HEAD" \
   --arg ts "$TIMESTAMP" \
   --arg root "$REPO_ROOT" \
   --arg nuqs "$NUQS_VERSION" \
   '{ meta: { repoRoot: $root, gitHead: $head, scannedAt: $ts, nuqsVersion: $nuqs }, matches: . }' \
   "$TMP_JSON" > "$OUT_FILE"

TOTAL=$(jq '.matches | length' "$OUT_FILE")
echo "Scan complete: $TOTAL match(es) across $(jq '[.matches[].codemod] | unique | length' "$OUT_FILE") codemod(s)"
echo "Wrote: $OUT_FILE"
echo "Run 'scripts/report.sh' to render a human-readable dry-run."
