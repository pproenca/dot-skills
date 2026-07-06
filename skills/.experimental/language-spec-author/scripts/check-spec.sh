#!/usr/bin/env bash
# check-spec.sh — lint a language-spec draft for the structural holes that make a spec
# unimplementable. Part of: language-spec-author
#
# It cannot judge whether the semantics are *correct* (only a cold-read implementer can),
# but it catches the mechanical gaps: missing sections, unresolved placeholders, missing
# grammar notation, and an under-specified conformance/error surface. Reports PASS / WARN
# / FAIL per check and exits non-zero if any check FAILs.

set -euo pipefail

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: check-spec.sh <spec-file.md>" >&2
  exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "Error: file not found: $FILE" >&2
  exit 1
fi

fails=0
warns=0
pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33mWARN\033[0m  %s\n' "$1"; warns=$((warns + 1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fails=$((fails + 1)); }

# Heading lines only (markdown '#'), lowercased, for section detection.
headings="$(grep -E '^#{1,6} ' "$FILE" | tr '[:upper:]' '[:lower:]' || true)"
has_heading() { printf '%s\n' "$headings" | grep -Eq "$1"; }

echo "Checking $FILE"
echo

# --- 1. Title ---------------------------------------------------------------
if grep -Eq '^# +\S' "$FILE"; then
  pass "Has an H1 title."
else
  fail "No H1 title (# ...). The spec needs a name."
fi

# --- 2. Required sections ---------------------------------------------------
# Mandatory for any implementable language; absence is a FAIL.
check_required() { # <regex> <label>
  if has_heading "$1"; then pass "Section present: $2."
  else fail "Missing required section: $2."; fi
}
check_required 'overview|purpose|principle'      "Overview / purpose & principles"
check_required 'lexic'                           "Lexical grammar"
check_required 'syntac|syntax|structural grammar' "Syntactic grammar"
check_required 'valid|static semantics'          "Validation (static semantics)"
check_required 'conformance'                     "Conformance"

# Conditional: expected for executable/typed languages; absence is a WARN, because a
# pure data/config format may legitimately have no execution or type system.
check_optional() { # <regex> <label>
  if has_heading "$1"; then pass "Section present: $2."
  else warn "No '$2' section — fine if this language has none, but say so explicitly."; fi
}
check_optional 'semantic model|type system'      "Semantic model / type system"
check_optional 'execution|evaluat|dynamic semantics' "Execution (dynamic semantics)"
check_optional 'response|output|result'          "Response / output & error format"

# --- 3. Unresolved placeholders ---------------------------------------------
# Scan outside HTML comment blocks (instructional comments are not holes). Catches
# TODO/TBD/FIXME/XXX/??? plus unfilled {{TEMPLATE}} vars from a hand-copied skeleton.
markers="$(awk '
  index($0, "<!--") { inc = 1 }
  inc == 0 && /TODO|TBD|FIXME|XXX|\?\?\?|[{][{][A-Z_]+[}][}]/ { printf "%d:%s\n", NR, $0 }
  index($0, "-->") { inc = 0 }
' "$FILE")"
if [[ -z "$markers" ]]; then
  pass "No unresolved placeholders (TODO/TBD/FIXME/XXX/??? or {{TEMPLATE}} vars)."
else
  n="$(printf '%s\n' "$markers" | grep -c . || true)"
  fail "$n unresolved placeholder(s) — each marks a hole an implementer cannot fill:"
  printf '%s\n' "$markers" | sed 's/^/          /'
fi

# --- 4. Grammar notation ----------------------------------------------------
# Lexical productions use '::', syntactic use ':'. Look for production-like lines.
if grep -Eq '^[[:space:]]*[A-Za-z][A-Za-z0-9_]*[[:space:]]*::' "$FILE"; then
  pass "Lexical grammar notation (::) present."
else
  warn "No lexical production (Name :: ...) found — token grammar may be missing or using ad-hoc notation."
fi
if grep -Eq '^[[:space:]]*[A-Za-z][A-Za-z0-9_]*[[:space:]]*:[^:]' "$FILE"; then
  pass "Syntactic grammar notation (:) present."
else
  warn "No syntactic production (Name : ...) found — structural grammar may be missing or using ad-hoc notation."
fi

# --- 5. Conformance keywords ------------------------------------------------
if grep -Eq '\b(MUST|SHALL|SHOULD|MAY|REQUIRED|RECOMMENDED|OPTIONAL)\b' "$FILE"; then
  pass "Uses RFC 2119 conformance keywords."
else
  warn "No MUST/SHOULD/MAY keywords — requirement strength is ambiguous; adopt RFC 2119."
fi
if grep -qiE '2119|8174' "$FILE"; then
  pass "References RFC 2119 / 8174."
else
  warn "Conformance section does not cite RFC 2119 (or 8174) — declare how the keywords are interpreted."
fi

# --- 6. Validation carries counter-examples ---------------------------------
if grep -qiE 'counter-?example' "$FILE"; then
  pass "Validation includes counter-example(s)."
else
  warn "No counter-examples found — each validation rule should show the smallest invalid case."
fi

# --- 7. Execution algorithms return -----------------------------------------
if has_heading 'execution|evaluat|dynamic semantics'; then
  if grep -qE '\bReturn\b' "$FILE"; then
    pass "Execution algorithms use explicit Return steps."
  else
    warn "Execution section present but no 'Return' step — algorithms should return (or raise a defined error) on every path."
  fi
fi

# --- Summary ----------------------------------------------------------------
echo
if [[ "$fails" -gt 0 ]]; then
  printf '\033[31mFAIL\033[0m: %d failure(s), %d warning(s). Fix every FAIL before circulating the spec.\n' "$fails" "$warns"
  exit 1
elif [[ "$warns" -gt 0 ]]; then
  printf '\033[33mPASS with %d warning(s).\033[0m Address the warnings unless each is a deliberate, stated choice.\n' "$warns"
  exit 0
else
  printf '\033[32mPASS\033[0m: no structural holes found. Now do the cold-read test — hand it to an implementer.\n'
  exit 0
fi
