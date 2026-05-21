#!/usr/bin/env bash
# new-pep.sh — Scaffold a new Python Enhancement Proposal (PEP) reStructuredText file.
# Part of: python-pep-author
#
# Fills the RFC 2822 header preamble from the bundled PEP template, sets a Draft
# status and today's Created date, and enforces the 44-character title limit.
# PEP numbers are assigned by the PEP editors, so the number defaults to a 9999
# placeholder — replace it once a number is assigned.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../assets/templates/pep-template.rst"

usage() {
  cat >&2 <<'EOF'
Usage:
  new-pep.sh --title "<title>" --author "<Name <email>>" --type <type> [options]

Required:
  --title   "<title>"          Short PEP title (max 44 characters)
  --author  "<Name <email>>"   e.g. "Random J. User <random@example.com>"
  --type    <type>             "Standards Track" | Informational | Process

Options:
  --out            <path>      Output file (default: ./pep-<NNNN>.rst)
  --pep            <number>    PEP number (default: 9999 — editors assign the real one)
  --status         <status>    Initial status (default: Draft)
  --python-version <M.N>       Target Python version (Standards Track only)
  -h, --help                   Show this help

Example:
  new-pep.sh --title "Add frobnication to the stdlib" \
             --author "Random J. User <random@example.com>" \
             --type "Standards Track" --python-version 3.15
EOF
  exit "${1:-1}"
}

# --- Defaults ---
TITLE=""
AUTHOR=""
TYPE=""
PEP_NUM="9999"
STATUS="Draft"
PYVER=""
OUT=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)          TITLE="${2:-}"; shift 2 ;;
    --author)         AUTHOR="${2:-}"; shift 2 ;;
    --type)           TYPE="${2:-}"; shift 2 ;;
    --pep)            PEP_NUM="${2:-}"; shift 2 ;;
    --status)         STATUS="${2:-}"; shift 2 ;;
    --python-version) PYVER="${2:-}"; shift 2 ;;
    --out)            OUT="${2:-}"; shift 2 ;;
    -h|--help)        usage 0 ;;
    *) echo "Error: unknown argument: $1" >&2; usage ;;
  esac
done

# --- Validate template ---
if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found at $TEMPLATE" >&2
  echo "       This script must run from inside the python-pep-author skill." >&2
  exit 1
fi

# --- Validate required arguments ---
missing=""
[[ -z "$TITLE" ]]  && missing="$missing --title"
[[ -z "$AUTHOR" ]] && missing="$missing --author"
[[ -z "$TYPE" ]]   && missing="$missing --type"
if [[ -n "$missing" ]]; then
  echo "Error: missing required argument(s):$missing" >&2
  usage
fi

# --- Validate type ---
case "$TYPE" in
  "Standards Track"|"Informational"|"Process") ;;
  *) echo "Error: --type must be 'Standards Track', 'Informational', or 'Process' (got: '$TYPE')" >&2; exit 1 ;;
esac

# --- Python-Version applies to Standards Track only (PEP 1) ---
if [[ -n "$PYVER" && "$TYPE" != "Standards Track" ]]; then
  echo "Error: --python-version applies to Standards Track PEPs only (type is '$TYPE')." >&2
  echo "       Drop --python-version, or set --type 'Standards Track'." >&2
  exit 1
fi

# --- Validate title length ---
if (( ${#TITLE} > 44 )); then
  echo "Error: --title is ${#TITLE} characters; PEP titles must be at most 44." >&2
  exit 1
fi

# --- Validate PEP number is numeric (for filename zero-padding) ---
if ! [[ "$PEP_NUM" =~ ^[0-9]+$ ]]; then
  echo "Error: --pep must be a number (got: '$PEP_NUM')" >&2
  exit 1
fi
PADDED="$(printf '%04d' "$PEP_NUM")"

# --- Derive Created date and output path ---
# Force the C locale so the month is always the English three-letter form PEP 1
# requires (e.g. "May"); +%b is locale-sensitive otherwise.
CREATED="$(LC_ALL=C date +%d-%b-%Y)"
[[ -z "$OUT" ]] && OUT="./pep-${PADDED}.rst"

# --- Format the author(s) onto RFC 2822 continuation lines (one per line) ---
# PEP 1 requires each author on a separate continuation line indented 8 spaces.
format_authors() {
  local raw="$1" out="" a
  local IFS=','
  read -ra parts <<< "$raw"
  for a in "${parts[@]}"; do
    a="${a#"${a%%[![:space:]]*}"}"   # ltrim
    a="${a%"${a##*[![:space:]]}"}"   # rtrim
    [[ -z "$a" ]] && continue
    if [[ -z "$out" ]]; then
      out="$a"
    else
      out="$out,"$'\n'"        $a"
    fi
  done
  printf '%s' "$out"
}
AUTHOR="$(format_authors "$AUTHOR")"

if [[ -e "$OUT" ]]; then
  echo "Error: $OUT already exists. Choose a different --out or remove it first." >&2
  exit 1
fi

# --- Render the template (literal substitution, safe for <, >, &, / in values) ---
# Drop the Python-Version line entirely when no version is supplied.
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$PYVER" && "$line" == Python-Version:* ]]; then
    continue
  fi
  line="${line//@@PEP@@/$PEP_NUM}"
  line="${line//@@TITLE@@/$TITLE}"
  line="${line//@@AUTHOR@@/$AUTHOR}"
  line="${line//@@TYPE@@/$TYPE}"
  line="${line//@@STATUS@@/$STATUS}"
  line="${line//@@CREATED@@/$CREATED}"
  line="${line//@@PYTHON_VERSION@@/$PYVER}"
  printf '%s\n' "$line"
done < "$TEMPLATE" > "$OUT"

echo "Created $OUT"
echo "  PEP:     $PEP_NUM (placeholder — PEP editors assign the real number)"
echo "  Title:   $TITLE"
echo "  Type:    $TYPE"
echo "  Status:  $STATUS"
echo "  Created: $CREATED"
echo
echo "Next steps:"
echo "  1. Fill in the body sections (see references/sections.md)."
echo "  2. Lint it:  $SCRIPT_DIR/check-pep.sh $OUT"
echo
echo "Note: 'Created' is set to today. PEP 1 defines it as the date the PEP is"
echo "      assigned a number — update it if a number is assigned on a later date."
