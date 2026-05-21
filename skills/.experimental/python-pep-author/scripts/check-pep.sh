#!/usr/bin/env bash
# check-pep.sh — Lint a PEP draft against PEP 1 / PEP 12 rules.
# Part of: python-pep-author
#
# Checks the RFC 2822 header preamble and required structure, reporting each
# check as PASS / WARN / FAIL. Exits non-zero if any check FAILs so it can gate
# a commit or PR.

set -euo pipefail

usage() {
  echo "Usage: check-pep.sh <pep-file.rst>" >&2
  exit "${1:-1}"
}

[[ $# -eq 1 ]] || usage
case "$1" in -h|--help) usage 0 ;; esac
FILE="$1"
[[ -f "$FILE" ]] || { echo "Error: file not found: $FILE" >&2; exit 1; }

PASS=0; WARN=0; FAIL=0
pass() { printf '  PASS  %s\n' "$1"; PASS=$((PASS + 1)); }
warn() { printf '  WARN  %s\n' "$1"; WARN=$((WARN + 1)); }
fail() { printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL + 1)); }

# --- Extract the header preamble: everything before the first blank line ---
HEADER="$(awk 'NF==0{exit} {print}' "$FILE")"

header_value() {
  # $1 = field name; echoes the first value (lead text stripped), empty if absent.
  printf '%s\n' "$HEADER" | sed -n "s/^$1:[[:space:]]*//p" | head -n1
}
has_value() {
  # True only if the field is present AND has a non-empty value. The PEP template
  # ships optional fields as empty "Field:" lines, so presence alone is not enough.
  [[ -n "$(header_value "$1")" ]]
}

echo "Linting PEP: $FILE"
echo

# --- Required headers (PEP 1) — must be present AND non-empty ---
for f in PEP Title Author Status Type Created; do
  if has_value "$f"; then
    pass "required header present: $f"
  else
    fail "missing or empty required header: $f"
  fi
done

# --- Title length (max 44) ---
TITLE="$(header_value Title)"
if [[ -n "$TITLE" ]]; then
  if (( ${#TITLE} <= 44 )); then
    pass "Title is ${#TITLE} chars (<= 44)"
  else
    fail "Title is ${#TITLE} chars (max 44): \"$TITLE\""
  fi
fi

# --- Type is one of the three valid values ---
TYPE="$(header_value Type)"
case "$TYPE" in
  "Standards Track"|"Informational"|"Process") pass "Type is valid: $TYPE" ;;
  "") : ;; # already reported missing above
  *) fail "Type must be 'Standards Track', 'Informational', or 'Process' (got: '$TYPE')" ;;
esac

# --- Status is a recognised value ---
STATUS="$(header_value Status)"
case "$STATUS" in
  Draft|Active|Accepted|Provisional|Deferred|Rejected|Withdrawn|Final|Superseded)
    pass "Status is valid: $STATUS" ;;
  "") : ;;
  *) fail "Status is not a recognised value (got: '$STATUS')" ;;
esac

# --- Created date format dd-mmm-yyyy ---
CREATED="$(header_value Created)"
if [[ -n "$CREATED" ]]; then
  if printf '%s' "$CREATED" | grep -qE '^[0-3][0-9]-[A-Z][a-z]{2}-[0-9]{4}$'; then
    pass "Created is dd-mmm-yyyy: $CREATED"
  else
    fail "Created must be dd-mmm-yyyy, e.g. 21-May-2026 (got: '$CREATED')"
  fi
fi

# --- Python-Version: expected on Standards Track, disallowed elsewhere ---
if [[ "$TYPE" == "Standards Track" ]]; then
  if has_value Python-Version; then
    pass "Python-Version present (Standards Track)"
  else
    warn "Standards Track PEPs usually set Python-Version"
  fi
elif [[ -n "$TYPE" ]] && has_value Python-Version; then
  warn "Python-Version is set but Type is '$TYPE' (Python-Version is for Standards Track only)"
fi

# --- Discussions-To expected once past Draft ---
if [[ -n "$STATUS" && "$STATUS" != "Draft" ]]; then
  if has_value Discussions-To; then
    pass "Discussions-To present"
  else
    warn "Status is '$STATUS' but Discussions-To is empty"
  fi
fi

# --- Resolution required for resolved Standards Track PEPs ---
case "$STATUS" in
  Accepted|Rejected|Withdrawn|Final)
    if has_value Resolution; then
      pass "Resolution header present for status $STATUS"
    elif [[ "$TYPE" == "Standards Track" ]]; then
      fail "Standards Track PEP in status $STATUS must have a Resolution header"
    else
      warn "Status $STATUS usually records a Resolution link"
    fi
    ;;
esac

# --- Superseded consistency ---
if [[ "$STATUS" == "Superseded" ]] && ! has_value Superseded-By; then
  warn "Status is Superseded but no Superseded-By header"
fi

# --- Abstract section (strongly recommended) ---
if grep -qE '^Abstract[[:space:]]*$' "$FILE"; then
  pass "Abstract section present"
else
  warn "no 'Abstract' section found (strongly recommended)"
fi

# --- Mandatory CC0 copyright notice ---
if grep -q "CC0-1.0-Universal" "$FILE"; then
  pass "Copyright / CC0-1.0-Universal notice present"
else
  fail "missing mandatory CC0-1.0-Universal copyright notice"
fi

echo
echo "Summary: $PASS passed, $WARN warnings, $FAIL failed"
if (( FAIL > 0 )); then
  echo "Result: FAIL — fix the items above before submitting." >&2
  exit 1
fi
if (( WARN > 0 )); then
  echo "Result: OK with $WARN warning(s)"
else
  echo "Result: OK"
fi
