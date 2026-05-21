#!/usr/bin/env python3
"""utilization-vs-throughput.py — Detect the utilization trap (busy != productive).

Theory of Constraints: high utilization is NOT a goal. "Activating a resource is
not the same as utilizing it" — running a non-constraint flat-out only piles up
WIP. A correctly-subordinated non-constraint SHOULD idle part of the time. Only
the constraint should approach 100% busy. This script ranks stages by
utilization, identifies the likely constraint (highest utilization), and flags
over-activated non-constraints and the no-resource-saturated case (a policy
constraint).

For each stage you supply busy time, available time, and items completed over
the same window. Utilization = busy / available. Throughput = completed / window.

Usage:
  utilization-vs-throughput.py "<name>:<busy>:<available>:<completed>" [more...]

Parameters:
  "<name>:<busy>:<available>:<completed>"
        name       stage label
        busy       time the stage was actively working (any unit, consistent)
        available  total time the stage could have worked (same unit)
        completed  items the stage finished in that window
        Provide one quoted argument per stage.

Example:
  utilization-vs-throughput.py \
    "lint:5:60:40" "build:28:60:40" "test:59:60:38" "deploy:9:60:38"
  # -> test ~98% busy = constraint; lint/build flagged if >85% but not constraint.

Expected output: a per-stage table (utilization%, throughput), the identified
constraint, and a verdict — over-activated non-constraints to subordinate, or
"no resource saturated -> suspect a policy constraint."
"""
import argparse
import sys

OVER_ACTIVATED = 85.0   # % utilization considered "running hot"
SATURATED = 95.0        # % utilization considered effectively the constraint
SLACK_SYSTEM = 70.0     # if every stage is below this, suspect a policy constraint


def parse_stage(spec: str):
    parts = spec.split(":")
    if len(parts) != 4:
        raise ValueError(f"'{spec}' must be name:busy:available:completed")
    name, busy_s, avail_s, done_s = parts
    busy, avail, done = float(busy_s), float(avail_s), float(done_s)
    if avail <= 0:
        raise ValueError(f"'{name}': available time must be > 0")
    if busy < 0 or done < 0:
        raise ValueError(f"'{name}': busy and completed must be >= 0")
    if busy > avail:
        raise ValueError(f"'{name}': busy ({busy}) cannot exceed available ({avail})")
    return {
        "name": name,
        "util": busy / avail * 100.0,
        "tput": done / avail,
        "done": done,
    }


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Detect the utilization trap: high utilization, low throughput."
    )
    ap.add_argument("stages", nargs="+",
                    help='One per stage: "name:busy:available:completed".')
    args = ap.parse_args()

    try:
        stages = [parse_stage(s) for s in args.stages]
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    constraint = max(stages, key=lambda s: s["util"])

    print(f"{'STAGE':<14}{'UTIL%':>8}{'THROUGHPUT':>12}{'':>4}NOTE")
    for s in sorted(stages, key=lambda x: x["util"], reverse=True):
        note = ""
        if s is constraint and s["util"] >= SATURATED:
            note = "<-- CONSTRAINT (saturated)"
        elif s is constraint:
            note = "<-- highest utilization (likely constraint)"
        elif s["util"] >= OVER_ACTIVATED:
            note = "OVER-ACTIVATED non-constraint -> subordinate (let it idle)"
        print(f"{s['name']:<14}{s['util']:>7.1f}%{s['tput']:>12.3f}    {note}")
    print()

    max_util = constraint["util"]
    over = [s["name"] for s in stages
            if s is not constraint and s["util"] >= OVER_ACTIVATED]

    if max_util < SLACK_SYSTEM:
        print("VERDICT: NO RESOURCE SATURATED")
        print(f"  Every stage is below {SLACK_SYSTEM:.0f}% utilization yet throughput is "
              "limited. No physical resource is the constraint -> suspect a POLICY "
              "constraint (batching, serialization, a gate, or a wrong metric). "
              "See policy-constraint-tree.md.")
    elif over:
        print("VERDICT: UTILIZATION TRAP")
        print(f"  '{constraint['name']}' is the constraint ({max_util:.0f}% busy), but "
              f"{', '.join(over)} run hot (>={OVER_ACTIVATED:.0f}%) without being the "
              "constraint — activating, not utilizing. SUBORDINATE them to the "
              "constraint's pace; let them idle. See utilization-trap-tree.md.")
    else:
        print("VERDICT: BALANCED")
        print(f"  '{constraint['name']}' is the constraint ({max_util:.0f}% busy) and "
              "non-constraints have appropriate slack. Apply the Five Focusing Steps to "
              "the constraint (find-the-constraint-tree.md).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
