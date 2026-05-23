#!/usr/bin/env bash
# verify.sh — run the full metric-validation harness and report PASS/FAIL per property.
# READ-ONLY: it computes and reports; it never modifies the metric, the corpus, or external state.
#
# Usage:
#   bash verify.sh                                  # uses config.json (or the bundled example metric)
#   METRIC_CMD="python3 path/to/mymetric.py" bash verify.sh
#
# Each property check maps to a category of the deterministic-metric-design skill.
set -euo pipefail  # checks are guarded with '|| rc=$?', so every check still runs to completion

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"

echo "== metric-validation-harness =="
echo "metric_cmd:   $METRIC_CMD"
echo "baseline_cmd: $BASELINE_CMD"
echo "corpus:       $LABELS_CSV"
echo

run_check() {  # run_check <label> <maps-to> <script>
  echo "── $1  ($2)"
  local rc=0
  if [[ "$3" == *.py ]]; then
    python3 "$HERE/$3" || rc=$?
  else
    bash "$HERE/$3" || rc=$?
  fi
  echo
  return $rc
}

total_fail=0
run_check "determinism"                   "det-"          "check-determinism.sh"  || total_fail=$((total_fail + 1))
run_check "invariance & anti-gaming"      "prop- / game-" "check-invariance.sh"   || total_fail=$((total_fail + 1))
run_check "monotonicity & discrimination" "prop-"         "check-monotonicity.sh" || total_fail=$((total_fail + 1))
run_check "robustness & range"            "prop-"         "check-robustness.sh"   || total_fail=$((total_fail + 1))
run_check "tractability"                  "comp-"         "check-tractability.py" || total_fail=$((total_fail + 1))
run_check "construct validity"            "valid-"        "check-validity.py"     || total_fail=$((total_fail + 1))

echo "════════════════════════════════════════════"
if [[ $total_fail -eq 0 ]]; then
  echo "RESULT: all property checks passed"
  exit 0
fi
echo "RESULT: $total_fail check group(s) failed — see the FAIL lines above"
exit 1
