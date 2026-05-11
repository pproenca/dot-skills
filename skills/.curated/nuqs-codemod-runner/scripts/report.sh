#!/usr/bin/env bash
# report.sh — Render scan.json as a human-readable dry-run report.
# Part of: nuqs-codemod-runner
#
# Output: markdown to stdout. The orchestrating agent shows this to the user verbatim
# and asks for explicit confirmation before invoking apply.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$SKILL_ROOT}"
SCAN_FILE="${1:-$DATA_DIR/scan.json}"

if [[ ! -f "$SCAN_FILE" ]]; then
  echo "Error: scan file '$SCAN_FILE' not found." >&2
  echo "Run 'scripts/scan.sh <repo-root>' first." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is not installed." >&2
  exit 1
fi

# --- Header ---
REPO=$(jq -r '.meta.repoRoot' "$SCAN_FILE")
HEAD=$(jq -r '.meta.gitHead' "$SCAN_FILE")
SCANNED=$(jq -r '.meta.scannedAt' "$SCAN_FILE")
NUQS_VER=$(jq -r '.meta.nuqsVersion' "$SCAN_FILE")
TOTAL=$(jq '.matches | length' "$SCAN_FILE")

cat <<HEADER
# nuqs Codemod — Dry-Run Report

- **Repo:** \`$REPO\`
- **Git HEAD:** \`$HEAD\`
- **Scanned at:** \`$SCANNED\`
- **Declared nuqs version:** \`$NUQS_VER\`
- **Total matches:** **$TOTAL**

HEADER

if [[ "$TOTAL" -eq 0 ]]; then
  echo "Nothing to migrate. You're already on current nuqs idioms."
  exit 0
fi

# --- Per-codemod sections ---
mapfile -t CODEMODS < <(jq -r '[.matches[].codemod] | unique | .[]' "$SCAN_FILE")

declare -A DESCRIPTIONS=(
  [throttle-ms]="Replace deprecated \`throttleMs: N\` with \`limitUrlUpdates: throttle(N)\` and add the \`throttle\` import. (nuqs v2.5)"
  [manual-debounce]="Replace hand-rolled setTimeout/useState debounce around a nuqs setter with built-in \`limitUrlUpdates: debounce(N)\`. (nuqs v2.5)"
  [unchecked-json-cast]="\`parseAsJson\` requires a runtime validator. Unchecked casts (or no argument) let attacker-controlled URLs into your app. Inserts a type-guard stub or Standard Schema bridge."
  [react-router-unversioned]="Pin the React Router adapter version explicitly. The unversioned \`nuqs/adapters/react-router\` import is removed in nuqs v3."
  [parser-builder-type]="\`ParserBuilder<T>\` was renamed to \`SingleParserBuilder<T>\` in nuqs v2.7. The old name is deprecated and will be removed."
)

for codemod in "${CODEMODS[@]}"; do
  COUNT=$(jq --arg c "$codemod" '[.matches[] | select(.codemod == $c)] | length' "$SCAN_FILE")
  echo
  echo "## \`$codemod\` — $COUNT match(es)"
  echo
  echo "${DESCRIPTIONS[$codemod]:-No description.}"
  echo
  echo "| File | Line | Snippet |"
  echo "|------|------|---------|"
  jq -r --arg c "$codemod" '
    .matches[]
    | select(.codemod == $c)
    | "| `\(.path)` | \(.line) | `\(.snippet | gsub("\\|"; "\\|") | .[0:120])` |"
  ' "$SCAN_FILE"
done

cat <<FOOTER

---

## Next Steps

1. Review the table(s) above.
2. To apply ALL codemods, run: \`scripts/apply.sh\`
3. To apply just one, run: \`scripts/apply.sh --filter <codemod-id>\` (e.g. \`--filter throttle-ms\`)
4. \`apply.sh\` will refuse to run if the working tree is dirty. Commit or stash first.

After \`apply.sh\` succeeds, \`verify.sh\` runs typecheck + lint automatically and reverts on failure.
FOOTER
