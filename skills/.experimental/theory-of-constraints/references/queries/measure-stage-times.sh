#!/usr/bin/env bash
# measure-stage-times.sh — Time each stage of a pipeline to find the constraint candidate.
#
# Theory of Constraints: the stage that dominates end-to-end wall-clock is the
# first suspect for the system's constraint. This script runs each stage you
# name, times it (optionally averaged over multiple runs), and ranks stages by
# mean duration with each stage's share of total wall-clock.
#
# Usage:
#   measure-stage-times.sh [--runs N] "<name>=<command>" ["<name>=<command>" ...]
#
# Parameters:
#   --runs N        How many times to run each stage; reports the mean.
#                   Default: 1. Use >=3 when run-to-run variance is high
#                   (see moving-constraint-tree.md).
#   "<name>=<cmd>"  A stage label and the shell command that performs it. The
#                   command IS EXECUTED, so pass real, side-effect-acceptable
#                   commands (a build, a test run, a script). Quote each pair.
#
# Example:
#   measure-stage-times.sh --runs 3 \
#     "install=npm ci" "build=npm run build" "test=npm test" "lint=npm run lint"
#
# Expected output (ranked slowest first):
#   STAGE            MEAN(s)    SHARE   RUNS
#   test              82.4000   61.2%      3  <-- CONSTRAINT CANDIDATE
#   build             28.1000   20.9%      3
#   install           18.3000   13.6%      3
#   lint               5.7000    4.2%      3
#   TOTAL            134.5000
#
# A stage flagged CONSTRAINT CANDIDATE (>=40% of total wall-clock, OR the top
# stage at >=2x the next) is your first suspect. Confirm it with measure-wip.sh,
# then apply the Five Focusing Steps (see find-the-constraint-tree.md).
set -euo pipefail

RUNS=1
if [[ "${1:-}" == "--runs" ]]; then
  RUNS="${2:-}"
  shift 2 || { echo "error: --runs needs a value." >&2; exit 1; }
fi

case "$RUNS" in
  ''|*[!0-9]*) echo "error: --runs must be a positive integer (got '$RUNS')." >&2; exit 1 ;;
esac
[[ "$RUNS" -ge 1 ]] || { echo "error: --runs must be >= 1." >&2; exit 1; }

if [[ $# -lt 1 ]]; then
  echo "error: provide at least one stage as \"name=command\"." >&2
  echo "usage: $0 [--runs N] \"name=command\" [\"name=command\" ...]" >&2
  exit 1
fi

# High-resolution epoch seconds; falls back to whole seconds if python3 absent.
_now() { python3 -c 'import time; print(time.time())' 2>/dev/null || date +%s; }

names=()
means=()
total=0

for pair in "$@"; do
  if [[ "$pair" != *=* ]]; then
    echo "error: '$pair' is not in name=command form." >&2
    exit 1
  fi
  name="${pair%%=*}"
  cmd="${pair#*=}"
  sum=0
  for ((i=1; i<=RUNS; i++)); do
    start="$(_now)"
    if ! bash -c "$cmd" >/dev/null 2>&1; then
      echo "warn: stage '$name' exited non-zero on run $i (timing still recorded)." >&2
    fi
    end="$(_now)"
    dur="$(awk -v a="$start" -v b="$end" 'BEGIN{printf "%.4f", b-a}')"
    sum="$(awk -v s="$sum" -v d="$dur" 'BEGIN{printf "%.4f", s+d}')"
  done
  mean="$(awk -v s="$sum" -v r="$RUNS" 'BEGIN{printf "%.4f", s/r}')"
  names+=("$name")
  means+=("$mean")
  total="$(awk -v t="$total" -v m="$mean" 'BEGIN{printf "%.4f", t+m}')"
done

# Sort stages by mean (descending) into parallel arrays, kept in this shell.
s_means=()
s_names=()
while read -r m idx; do
  [[ -z "$m" ]] && continue
  s_means+=("$m")
  s_names+=("${names[$idx]}")
done <<< "$(for i in "${!means[@]}"; do echo "${means[$i]} $i"; done | sort -rn)"

printf '%-16s %9s %8s %6s\n' "STAGE" "MEAN(s)" "SHARE" "RUNS"
for j in "${!s_means[@]}"; do
  m="${s_means[$j]}"
  name="${s_names[$j]}"
  share="$(awk -v m="$m" -v t="$total" 'BEGIN{ if (t>0) printf "%.1f", (m/t)*100; else print "0.0" }')"
  flag=""
  if awk -v m="$m" -v t="$total" 'BEGIN{exit !(t>0 && (m/t)>=0.40)}'; then
    flag="  <-- CONSTRAINT CANDIDATE (>=40% of total)"
  elif [[ "$j" -eq 0 && "${#s_means[@]}" -gt 1 ]]; then
    next="${s_means[1]}"
    if awk -v m="$m" -v n="$next" 'BEGIN{exit !(n>0 && (m/n)>=2)}'; then
      flag="  <-- CONSTRAINT CANDIDATE (>=2x next stage)"
    fi
  fi
  printf '%-16s %9s %7s%% %6s%s\n' "$name" "$m" "$share" "$RUNS" "$flag"
done
printf '%-16s %9s\n' "TOTAL" "$total"
