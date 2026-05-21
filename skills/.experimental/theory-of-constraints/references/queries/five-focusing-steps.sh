#!/usr/bin/env bash
# five-focusing-steps.sh — Walk the POOGI (Process Of Ongoing Improvement) for a constraint.
#
# Theory of Constraints is a loop, run strictly in order. This script prints the
# Five Focusing Steps as answerable prompts for a named constraint and goal
# metric, and appends a timestamped entry to the investigation log so recurring
# constraints (and elevations that didn't hold) become visible over time.
#
# It is non-interactive by design: it emits the prompts for the agent/user to
# answer, and logs that an investigation was opened. Do NOT skip steps —
# exploiting before elevating is what separates ToC from "throw resources at it."
#
# Usage:
#   five-focusing-steps.sh --constraint "<name>" [--metric "<goal metric>"] [--log <path>]
#
# Parameters:
#   --constraint "<name>"   The constraint you have identified (required).
#   --metric "<goal>"       The global throughput metric you are improving
#                           (e.g. "PRs merged/week"). Optional but recommended.
#   --log <path>            Investigation log file. Default:
#                           "${CLAUDE_PLUGIN_DATA:-$HOME/.claude}/toc-investigations.log".
#
# Example:
#   five-focusing-steps.sh --constraint "CI test stage" --metric "builds/hour"
#
# Expected output: the five step prompts to answer in order, plus confirmation
# that an entry was appended to the log. Record answers in
# ../assets/templates/report.md.
set -euo pipefail

CONSTRAINT=""
METRIC=""
LOG="${CLAUDE_PLUGIN_DATA:-$HOME/.claude}/toc-investigations.log"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --constraint) CONSTRAINT="${2:-}"; shift 2 || { echo "error: --constraint needs a value." >&2; exit 1; } ;;
    --metric)     METRIC="${2:-}";     shift 2 || { echo "error: --metric needs a value." >&2; exit 1; } ;;
    --log)        LOG="${2:-}";        shift 2 || { echo "error: --log needs a value." >&2; exit 1; } ;;
    *) echo "error: unknown argument '$1'." >&2; echo "usage: $0 --constraint \"<name>\" [--metric \"<goal>\"] [--log <path>]" >&2; exit 1 ;;
  esac
done

if [[ -z "$CONSTRAINT" ]]; then
  echo "error: --constraint is required." >&2
  echo "usage: $0 --constraint \"<name>\" [--metric \"<goal>\"] [--log <path>]" >&2
  exit 1
fi

metric_line="${METRIC:-(not set — define the global metric you are maximizing)}"

cat <<EOF
Five Focusing Steps for constraint: $CONSTRAINT
Goal metric: $metric_line
-----------------------------------------------------------------------------
1. IDENTIFY  — Confirm "$CONSTRAINT" is the binding constraint.
   - What evidence? (slowest stage, growing WIP in front of it, ~100% busy)
   - If unsure, stop and run measure-stage-times.sh / measure-wip.sh first.

2. EXPLOIT   — Get the MOST from it with NO new spend.
   - Is it ever idle, blocked, or doing avoidable/rework? Remove that.
   - Can its inputs be pre-staged so it never starves?
   - Re-measure $metric_line. Improved enough? If yes, STOP here.

3. SUBORDINATE — Pace every NON-constraint to this constraint.
   - Make non-constraints idle rather than build WIP in front of it (Drum-Buffer-Rope).
   - Cap released work to the constraint's actual rate.

4. ELEVATE   — Only now, add capacity to the constraint.
   - Parallelize / add a worker / shard / upgrade / split the batch.
   - Verify with throughput-accounting.py that T rose (not just OE).

5. REPEAT    — The constraint has moved. Re-identify from step 1.
   - INERTIA CHECK: remove any policy/buffer/rule tuned to the OLD constraint,
     or it becomes the new one. See moving-constraint-tree.md.
-----------------------------------------------------------------------------
Record your answers in ../assets/templates/report.md.
EOF

# Append a log entry (best-effort; never fail the run on logging issues).
ts="$(date '+%Y-%m-%d %H:%M:%S')"
if mkdir -p "$(dirname "$LOG")" 2>/dev/null && printf '%s\tconstraint=%s\tmetric=%s\n' "$ts" "$CONSTRAINT" "${METRIC:-unset}" >> "$LOG" 2>/dev/null; then
  echo ""
  echo "Logged investigation to: $LOG"
else
  echo "" >&2
  echo "warn: could not write log at '$LOG' (continuing without logging)." >&2
fi
