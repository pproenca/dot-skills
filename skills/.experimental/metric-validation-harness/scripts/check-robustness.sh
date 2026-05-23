#!/usr/bin/env bash
# check-robustness.sh — edge inputs (empty, single statement) must give a finite, in-range number,
# never a crash or NaN. Maps to prop-prove-boundedness-and-handle-empty.
# Set declared_min / declared_max in config.json to enforce the metric's claimed range.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

check_one() {  # check_one <label> <file>
  local label="$1" file="$2" val
  if ! val="$(metric_of "$file")"; then
    echo "FAIL: $label — metric crashed or returned a non-number on edge input"
    fail=$((fail + 1))
    return
  fi
  if [[ -n "$DECLARED_MIN" ]] && ! num_ge "$val" "$DECLARED_MIN"; then
    echo "FAIL: $label — value $val below declared min $DECLARED_MIN"
    fail=$((fail + 1))
    return
  fi
  if [[ -n "$DECLARED_MAX" ]] && ! num_ge "$DECLARED_MAX" "$val"; then
    echo "FAIL: $label — value $val above declared max $DECLARED_MAX"
    fail=$((fail + 1))
    return
  fi
  echo "PASS: $label — finite, in-range value ($val)"
  pass=$((pass + 1))
}

: > "$TMP/empty.py"                  # empty file
printf 'x = 0\n' > "$TMP/single.py" # single statement
check_one "empty input" "$TMP/empty.py"
check_one "single-statement input" "$TMP/single.py"

echo "check-robustness: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
