#!/usr/bin/env bash
# selftest.sh — prove the harness works end to end against the bundled example metric + fixtures.
# Positive: the AST-node metric (comment/whitespace-invariant) passes every check.
# Negative: the LOC baseline FAILS invariance — proving the harness actually catches a bad metric.
set -euo pipefail  # the failing commands here are all in 'if' conditions, so -e is safe

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fail=0

echo "### 1. Positive run — the AST-node metric should pass every property check"
if bash "$HERE/verify.sh"; then
  echo "[selftest] positive run PASSED"
else
  echo "[selftest] positive run FAILED — the bundled example metric should pass"
  fail=1
fi
echo

echo "### 2. Negative run — the gameable LOC baseline should FAIL invariance"
loc_cmd="python3 $HERE/examples/metric_loc.py"
if METRIC_CMD="$loc_cmd" bash "$HERE/check-invariance.sh" >/dev/null 2>&1; then
  echo "[selftest] negative check FAILED — LOC unexpectedly passed invariance (harness not discriminating)"
  fail=1
else
  echo "[selftest] negative check PASSED — harness correctly flags LOC as non-invariant / gameable"
fi
echo

if [[ $fail -eq 0 ]]; then
  echo "SELFTEST: PASS"
  exit 0
fi
echo "SELFTEST: FAIL"
exit 1
