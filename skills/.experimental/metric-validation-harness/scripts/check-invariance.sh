#!/usr/bin/env bash
# check-invariance.sh — cosmetic edits (comments, blank lines, whitespace) must not change the score.
# This is invariance (prop-prove-invariance-under-irrelevant-transforms) AND anti-gaming
# (game-make-cheapest-improvement-the-right-one): if cosmetic edits move it, it is gameable.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  name="$(basename "$f")"
  base="$(metric_of "$f")" || { echo "FAIL: $name — metric did not run"; fail=$((fail + 1)); continue; }
  variant="$TMP/$name"
  python3 "$HERE/lib/transforms.py" cosmetic "$f" "$variant"
  cos="$(metric_of "$variant")" || { echo "FAIL: $name — metric did not run on cosmetic variant"; fail=$((fail + 1)); continue; }
  if num_eq "$base" "$cos"; then
    echo "PASS: $name — invariant to cosmetic noise ($base)"
    pass=$((pass + 1))
  else
    echo "FAIL: $name — cosmetic noise moved the score ($base → $cos); it measures surface text and an optimizer can game it"
    fail=$((fail + 1))
  fi
done < <(list_fixtures)

echo "check-invariance: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
