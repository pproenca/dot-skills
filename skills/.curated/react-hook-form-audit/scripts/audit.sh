#!/usr/bin/env bash
# audit.sh — Orchestrate the React Hook Form audit on a Next.js codebase.
# Part of: react-hook-form-audit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_DIR/config.json"

usage() {
  cat >&2 <<EOF
Usage: $0 [--project <path>] [--dry-run]

Audits a Next.js App Router project for React Hook Form anti-patterns.

Options:
  --project <path>   Project root to audit. Defaults to project_root in config.json,
                     or the current working directory when that is empty.
  --dry-run          Skip writing the report file; print summary only.

Exit codes:
  0  No CRITICAL or HIGH findings
  1  CRITICAL or HIGH findings exist
  2  Configuration or environment error
EOF
}

PROJECT_OVERRIDE=""
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_OVERRIDE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

# --- Dependency checks ---
require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' is required but not installed." >&2
    echo "  Install with: $2" >&2
    exit 2
  fi
}
require rg "brew install ripgrep  # or your package manager equivalent"
require node "Install Node.js 18+ from https://nodejs.org or via your package manager"
require npm "Ships with Node.js — re-install Node if missing"
require jq "brew install jq  # or your package manager equivalent"

# --- Lazy-install ts-morph the first time we run ---
if [[ ! -d "$SCRIPT_DIR/node_modules/ts-morph" ]]; then
  echo "→ First run: installing ts-morph (one-time, ~30s)"
  (cd "$SCRIPT_DIR" && npm install --silent --no-audit --no-fund --prefer-offline) || {
    echo "ERROR: failed to install ts-morph. Run manually: cd $SCRIPT_DIR && npm install" >&2
    exit 2
  }
fi

# --- Resolve project root ---
PROJECT_ROOT="$PROJECT_OVERRIDE"
if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(jq -r '.project_root // ""' "$CONFIG_FILE")"
fi
if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(pwd)"
fi
if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "ERROR: project_root '$PROJECT_ROOT' is not a directory." >&2
  exit 2
fi
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
echo "Auditing: $PROJECT_ROOT"

# --- Resolve outputs ---
REPORT_PATH="$(jq -r '.report_path // ".rhf-audit-report.md"' "$CONFIG_FILE")"
JSON_REPORT_PATH="$(jq -r '.json_report_path // ""' "$CONFIG_FILE")"
RULE_LINK_BASE="$(jq -r '.rule_link_base // ""' "$CONFIG_FILE")"

# --- Step 1: Detect project ---
echo "→ Step 1/5: detecting Next.js + react-hook-form"
"$SCRIPT_DIR/detect-project.sh" "$PROJECT_ROOT" || exit 2

# --- Step 2: Collect candidate files ---
echo "→ Step 2/5: collecting candidate files"
FILES_JSON="$(mktemp -t rhf-audit-files.XXXXXX.json)"
FAST_JSON=""
AST_JSON=""
ALL_JSON=""
trap 'rm -f "$FILES_JSON" "$FAST_JSON" "$AST_JSON" "$ALL_JSON" 2>/dev/null || true' EXIT
"$SCRIPT_DIR/collect-files.sh" "$PROJECT_ROOT" "$CONFIG_FILE" > "$FILES_JSON"

FILE_COUNT="$(jq 'length' "$FILES_JSON")"
echo "  found $FILE_COUNT candidate file(s)"
if [[ "$FILE_COUNT" -eq 0 ]]; then
  echo "  no React Hook Form usages found — nothing to audit."
  exit 0
fi

# --- Step 3: Fast pass (ripgrep) ---
echo "→ Step 3/5: ripgrep fast pass"
FAST_JSON="$(mktemp -t rhf-audit-fast.XXXXXX.json)"
"$SCRIPT_DIR/detect-fast.sh" "$PROJECT_ROOT" "$FILES_JSON" > "$FAST_JSON"
FAST_COUNT="$(jq 'length' "$FAST_JSON")"
echo "  fast pass: $FAST_COUNT finding(s)"

# --- Step 4: AST pass (ts-morph) ---
echo "→ Step 4/5: ts-morph AST pass"
AST_JSON="$(mktemp -t rhf-audit-ast.XXXXXX.json)"
node "$SCRIPT_DIR/detect-ast.mjs" --project "$PROJECT_ROOT" --files "$FILES_JSON" > "$AST_JSON"
AST_COUNT="$(jq 'length' "$AST_JSON")"
echo "  AST pass: $AST_COUNT finding(s)"

# --- Step 5: Render report ---
echo "→ Step 5/5: rendering report"
ALL_JSON="$(mktemp -t rhf-audit-all.XXXXXX.json)"
jq -s 'add' "$FAST_JSON" "$AST_JSON" > "$ALL_JSON"

REPORT_OPTS=(--findings "$ALL_JSON" --project "$PROJECT_ROOT")
if [[ -n "$RULE_LINK_BASE" ]]; then
  REPORT_OPTS+=(--rule-link-base "$RULE_LINK_BASE")
fi

REPORT_MD="$(node "$SCRIPT_DIR/render-report.mjs" "${REPORT_OPTS[@]}")"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo ""
  echo "(dry-run) Report would be written to: $PROJECT_ROOT/$REPORT_PATH"
else
  printf '%s\n' "$REPORT_MD" > "$PROJECT_ROOT/$REPORT_PATH"
  echo "  wrote $PROJECT_ROOT/$REPORT_PATH"
  if [[ -n "$JSON_REPORT_PATH" ]]; then
    cp "$ALL_JSON" "$PROJECT_ROOT/$JSON_REPORT_PATH"
    echo "  wrote $PROJECT_ROOT/$JSON_REPORT_PATH"
  fi
fi

# --- Summary + exit code ---
echo ""
echo "── Summary ──"
jq -r '
  group_by(.severity)
  | map({severity: .[0].severity, count: length})
  | sort_by({"CRITICAL":0,"HIGH":1,"MEDIUM":2,"LOW":3}[.severity])
  | .[]
  | "  \(.severity)\t\(.count)"
' "$ALL_JSON"

CRIT_HIGH_COUNT="$(jq '[ .[] | select(.severity == "CRITICAL" or .severity == "HIGH") ] | length' "$ALL_JSON")"
if [[ "$CRIT_HIGH_COUNT" -gt 0 ]]; then
  echo ""
  echo "EXIT 1: $CRIT_HIGH_COUNT CRITICAL or HIGH finding(s) — see report"
  exit 1
fi
echo ""
echo "EXIT 0: no CRITICAL or HIGH findings"
