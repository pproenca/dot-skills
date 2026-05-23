#!/usr/bin/env bash
# check-determinism.sh — same input must yield the same number across runs and hash seeds.
# Maps to deterministic-metric-design: det-make-the-metric-a-pure-function,
# det-pin-iteration-and-tie-break-order.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"

pass=0
fail=0

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  name="$(basename "$f")"
  a="$(metric_of "$f")" || { echo "FAIL: $name — metric did not run"; fail=$((fail + 1)); continue; }
  b="$(metric_of "$f")" || { echo "FAIL: $name — metric did not run (2nd pass)"; fail=$((fail + 1)); continue; }
  c="$(PYTHONHASHSEED=0 metric_of "$f")" || c="ERR"
  d="$(PYTHONHASHSEED=1 metric_of "$f")" || d="ERR"
  if num_eq "$a" "$b" && num_eq "$a" "$c" && num_eq "$a" "$d"; then
    echo "PASS: $name — stable ($a) across repeats and hash seeds"
    pass=$((pass + 1))
  else
    echo "FAIL: $name — non-deterministic (repeats: $a,$b; seeds 0/1: $c,$d). Pin iteration/tie-break order; pass any time as input."
    fail=$((fail + 1))
  fi
done < <(list_fixtures)

echo "check-determinism: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
