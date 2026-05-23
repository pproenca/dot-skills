#!/usr/bin/env bash
# check-monotonicity.sh — adding code (a construct-increasing edit) must not LOWER the score,
# and the metric must discriminate across distinct inputs (not saturate).
# Maps to prop-prove-monotonicity and prop-ensure-sensitivity-to-relevant-change.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
values=()

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  name="$(basename "$f")"
  base="$(metric_of "$f")" || { echo "FAIL: $name — metric did not run"; fail=$((fail + 1)); continue; }
  values+=("$base")
  grown="$TMP/$name"
  python3 "$HERE/lib/transforms.py" grow "$f" "$grown" 50
  big="$(metric_of "$grown")" || { echo "FAIL: $name — metric did not run on grown variant"; fail=$((fail + 1)); continue; }
  if num_ge "$big" "$base"; then
    echo "PASS: $name — non-decreasing after adding code ($base → $big)"
    pass=$((pass + 1))
  else
    echo "FAIL: $name — score DROPPED after adding code ($base → $big); optimizing it could reward worse code"
    fail=$((fail + 1))
  fi
done < <(list_fixtures)

# Discrimination: distinct inputs must not all collapse to one value (saturation / no sensitivity).
distinct=0
if [[ ${#values[@]} -gt 0 ]]; then
  distinct="$(printf '%s\n' "${values[@]}" | sort -u | wc -l | tr -d ' ')"
fi
if [[ ${#values[@]} -ge 2 && $distinct -ge 2 ]]; then
  echo "PASS: discrimination — $distinct distinct values across ${#values[@]} fixtures (not saturated)"
  pass=$((pass + 1))
else
  echo "FAIL: discrimination — metric does not separate distinct inputs (saturated / no sensitivity)"
  fail=$((fail + 1))
fi

echo "check-monotonicity: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
