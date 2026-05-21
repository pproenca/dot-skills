#!/usr/bin/env bash
# measure-wip.sh — Count work-in-progress (WIP) waiting at each stage.
#
# Theory of Constraints: WIP accumulates immediately in front of the constraint,
# because the constraint can't consume work as fast as upstream produces it. The
# largest / fastest-growing inbox points straight at the bottleneck. Run this
# twice (use --again) to see which inbox GROWS — growth, not size alone, is the
# constraint signal.
#
# Each "probe" is a command whose STDOUT LINE COUNT is the WIP at that stage
# (e.g. open PRs awaiting review, files in a queue directory, pending jobs).
#
# Usage:
#   measure-wip.sh [--again SECONDS] "<name>=<command>" ["<name>=<command>" ...]
#
# Parameters:
#   --again SECONDS  Take a second reading after sleeping SECONDS, then report
#                    the delta per stage (+N = growing). Omit for a single
#                    snapshot. Default: single reading.
#   "<name>=<cmd>"   A stage label and a command that lists the waiting items,
#                    one per line. The command IS EXECUTED (read-only is
#                    expected). Quote each pair.
#
# Examples:
#   measure-wip.sh \
#     "review=gh pr list --state open --search 'review:required'" \
#     "ci-queue=gh run list --status queued" \
#     "deploy-queue=ls -1 ./deploy-queue"
#   measure-wip.sh --again 60 "review=gh pr list --state open"
#
# Expected output:
#   STAGE            WIP    DELTA
#   review            27      +4   <-- GROWING: constraint is at/just downstream
#   ci-queue           9      +0
#   deploy-queue       2      -1
#
# A stage whose WIP is largest AND growing (positive DELTA across readings)
# means the stage consuming that inbox is the constraint. Confirm it is busy
# (utilization-vs-throughput.py); if it is idle while its inbox grows, it is
# BLOCKED, not slow. See wip-accumulation-tree.md.
set -euo pipefail

AGAIN=""
if [[ "${1:-}" == "--again" ]]; then
  AGAIN="${2:-}"
  shift 2 || { echo "error: --again needs a value in seconds." >&2; exit 1; }
  case "$AGAIN" in
    ''|*[!0-9]*) echo "error: --again must be a positive integer (seconds)." >&2; exit 1 ;;
  esac
fi

if [[ $# -lt 1 ]]; then
  echo "error: provide at least one stage probe as \"name=command\"." >&2
  echo "usage: $0 [--again SECONDS] \"name=command\" [\"name=command\" ...]" >&2
  exit 1
fi

# Count lines emitted by a probe command (WIP at that stage).
_probe() {
  local cmd="$1"
  bash -c "$cmd" 2>/dev/null | grep -c '' || true
}

names=()
first=()
for pair in "$@"; do
  if [[ "$pair" != *=* ]]; then
    echo "error: '$pair' is not in name=command form." >&2
    exit 1
  fi
  names+=("${pair%%=*}")
  first+=("$(_probe "${pair#*=}")")
done

second=()
if [[ -n "$AGAIN" ]]; then
  echo "First reading taken; sleeping ${AGAIN}s for the second reading..." >&2
  sleep "$AGAIN"
  for pair in "$@"; do
    second+=("$(_probe "${pair#*=}")")
  done
fi

printf '%-16s %6s %8s\n' "STAGE" "WIP" "DELTA"
for i in "${!names[@]}"; do
  wip="${first[$i]}"
  delta="n/a"
  flag=""
  if [[ -n "$AGAIN" ]]; then
    d=$(( ${second[$i]} - ${first[$i]} ))
    wip="${second[$i]}"
    if [[ "$d" -gt 0 ]]; then
      delta="+$d"
      flag="  <-- GROWING: constraint at/just downstream"
    elif [[ "$d" -lt 0 ]]; then
      delta="$d"
    else
      delta="+0"
    fi
  fi
  printf '%-16s %6s %8s%s\n' "${names[$i]}" "$wip" "$delta" "$flag"
done

if [[ -z "$AGAIN" ]]; then
  echo "" >&2
  echo "Single snapshot only. Re-run with --again SECONDS to detect which inbox is GROWING" >&2
  echo "(growth, not size, identifies the constraint). See wip-accumulation-tree.md." >&2
fi
