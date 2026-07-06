#!/usr/bin/env bash
# new-spec.sh — scaffold an implementable language-spec draft from the template.
# Part of: language-spec-author
#
# Fills the skeleton's header fields and goal symbol so you start from a valid,
# correctly-structured document instead of hand-typing the section scaffolding.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../assets/templates/spec-template.md"

usage() {
  cat >&2 <<'EOF'
Usage: new-spec.sh --title "<Language name>" [options]

Required:
  --title "<name>"        Human name of the language (e.g. "AcmeQL").

Options:
  --goal-symbol "<Sym>"   Grammar start symbol (default: Document).
  --editors  "<names>"    Editor/author line (default: "TODO").
  --version  "<ver>"      Spec version (default: 0.1.0).
  --out      "<path>"     Output file (default: <slug>-spec.md in the cwd).
  -h, --help              Show this help.

Example:
  new-spec.sh --title "AcmeQL" --goal-symbol "Document" --editors "R. User <r@x.io>"
EOF
  exit "${1:-1}"
}

TITLE="" GOAL_SYMBOL="Document" EDITORS="TODO" VERSION="0.1.0" OUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)       TITLE="${2:-}"; shift 2 ;;
    --goal-symbol) GOAL_SYMBOL="${2:-}"; shift 2 ;;
    --editors)     EDITORS="${2:-}"; shift 2 ;;
    --version)     VERSION="${2:-}"; shift 2 ;;
    --out)         OUT="${2:-}"; shift 2 ;;
    -h|--help)     usage 0 ;;
    *) echo "Error: unknown argument '$1'" >&2; usage ;;
  esac
done

if [[ -z "$TITLE" ]]; then
  echo "Error: --title is required." >&2
  usage
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found at $TEMPLATE" >&2
  echo "Run this script from within the skill directory so it can find assets/templates/." >&2
  exit 1
fi

# Slug for the default filename: lowercase, non-alphanumeric -> dash, trim dashes.
slug="$(printf '%s' "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
[[ -z "$slug" ]] && slug="language"
: "${OUT:=${slug}-spec.md}"

if [[ -e "$OUT" ]]; then
  echo "Error: '$OUT' already exists. Choose another --out or remove it first." >&2
  exit 1
fi

CREATED="$(date +%Y-%m-%d)"

# Substitute placeholders with a literal index/substr splice — NOT a regex/replacement
# engine. Both awk gsub() and bash 5.2+ ${var//pat/repl} treat '&' in the replacement as
# "the matched text", which corrupts values like "AT&T"; sed treats '\' specially too.
# Values are passed through the environment (ENVIRON[]) so awk does not process '\'
# escapes in them either. This inserts every value verbatim, regardless of its content.
V_TITLE="$TITLE" V_STATUS="Draft" V_VERSION="$VERSION" V_CREATED="$CREATED" \
V_EDITORS="$EDITORS" V_GOAL="$GOAL_SYMBOL" \
awk '
  function rep(s, from, to,   out, p) {
    while ((p = index(s, from)) > 0) {
      out = out substr(s, 1, p - 1) to
      s = substr(s, p + length(from))
    }
    return out s
  }
  {
    $0 = rep($0, "{{TITLE}}",       ENVIRON["V_TITLE"])
    $0 = rep($0, "{{STATUS}}",      ENVIRON["V_STATUS"])
    $0 = rep($0, "{{VERSION}}",     ENVIRON["V_VERSION"])
    $0 = rep($0, "{{CREATED}}",     ENVIRON["V_CREATED"])
    $0 = rep($0, "{{EDITORS}}",     ENVIRON["V_EDITORS"])
    $0 = rep($0, "{{GOAL_SYMBOL}}", ENVIRON["V_GOAL"])
    print
  }
' "$TEMPLATE" > "$OUT"

echo "Created $OUT"
echo "Next: fill the TODO markers section by section, then run scripts/check-spec.sh $OUT"
