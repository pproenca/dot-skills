#!/usr/bin/env python3
"""throughput-accounting.py — Judge a change by its effect on the global goal.

Theory of Constraints measures a system with three numbers, not local efficiency:

  T  (Throughput)        — rate the system generates its goal unit
                           (PRs merged/week, requests/sec, task completions/session,
                           builds/hour). MORE is better.
  I  (Inventory/Investment) — work or money tied up in the system right now
                           (open WIP, queued items, capital). LESS is better.
  OE (Operating Expense) — rate of spend to turn I into T
                           (tokens/run, CI minutes, $/month, person-hours). LESS is better.

Goal: increase T while holding or reducing I and OE. A change that lowers OE or
speeds a stage but leaves T flat is a LOCAL OPTIMUM — "an hour saved at a
non-bottleneck is a mirage." This script computes the before/after deltas and
flags that pattern.

Usage:
  throughput-accounting.py --before T I OE --after T I OE [--tol PCT]

Parameters:
  --before T I OE   The three measures BEFORE the change (floats, any unit; keep
                    units consistent between before and after).
  --after  T I OE   The three measures AFTER the change.
  --tol PCT         Throughput-change tolerance, percent. A |dT| below this is
                    treated as "no real throughput change." Default: 5.

Example:
  # Build got 30% faster (OE down) but merges/week unchanged:
  throughput-accounting.py --before 20 12 100 --after 20 12 70
  # -> LOCAL OPTIMUM: OE fell 30% but throughput is flat.

Expected output: a before/after table, deltas, derived Net (T - OE) and a
verdict — one of: THROUGHPUT IMPROVED, LOCAL OPTIMUM, WIP INFLATED, or REGRESSION.
"""
import argparse
import sys


def pct(before: float, after: float) -> float:
    if before == 0:
        return float("inf") if after != 0 else 0.0
    return (after - before) / abs(before) * 100.0


def fmt_pct(p: float) -> str:
    if p == float("inf"):
        return "+inf%"
    sign = "+" if p >= 0 else ""
    return f"{sign}{p:.1f}%"


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Throughput accounting: judge a change by global T/I/OE deltas."
    )
    ap.add_argument("--before", nargs=3, type=float, required=True,
                    metavar=("T", "I", "OE"), help="Throughput, Inventory, Operating Expense BEFORE.")
    ap.add_argument("--after", nargs=3, type=float, required=True,
                    metavar=("T", "I", "OE"), help="Throughput, Inventory, Operating Expense AFTER.")
    ap.add_argument("--tol", type=float, default=5.0,
                    help="Throughput-change tolerance in percent (default 5).")
    args = ap.parse_args()

    t0, i0, oe0 = args.before
    t1, i1, oe1 = args.after

    for label, val in (("Inventory", i0), ("Inventory", i1)):
        if val < 0:
            print(f"error: {label} cannot be negative.", file=sys.stderr)
            return 1

    dT, dI, dOE = pct(t0, t1), pct(i0, i1), pct(oe0, oe1)
    net0, net1 = t0 - oe0, t1 - oe1

    print(f"{'MEASURE':<22}{'BEFORE':>12}{'AFTER':>12}{'DELTA':>10}")
    print(f"{'T  Throughput (↑)':<22}{t0:>12.3f}{t1:>12.3f}{fmt_pct(dT):>10}")
    print(f"{'I  Inventory (↓)':<22}{i0:>12.3f}{i1:>12.3f}{fmt_pct(dI):>10}")
    print(f"{'OE Operating Exp (↓)':<22}{oe0:>12.3f}{oe1:>12.3f}{fmt_pct(dOE):>10}")
    print(f"{'Net (T - OE) (↑)':<22}{net0:>12.3f}{net1:>12.3f}{fmt_pct(pct(net0, net1)):>10}")
    print()

    t_flat = abs(dT) < args.tol
    verdict, detail = "", ""

    if dT >= args.tol and t1 > t0:
        verdict = "THROUGHPUT IMPROVED"
        detail = ("T rose above tolerance. If the changed stage was the constraint, "
                  "this is real — re-identify the new constraint (find-the-constraint-tree.md).")
    elif t_flat and dOE <= -args.tol:
        verdict = "LOCAL OPTIMUM"
        detail = ("OE fell but throughput is flat — the classic mirage of the "
                  "non-bottleneck. You optimized a non-constraint. Keep the change only "
                  "if it is cheap and side-effect-free; redirect effort to the real "
                  "constraint (local-optimum-tree.md).")
    elif t_flat and dI >= args.tol:
        verdict = "WIP INFLATED"
        detail = ("Inventory grew with no throughput gain — you likely sped up or "
                  "parallelized a non-constraint, flooding the bottleneck. Subordinate it "
                  "and cap WIP (wip-accumulation-tree.md).")
    elif dT <= -args.tol:
        verdict = "REGRESSION"
        detail = ("Throughput fell. Revert, or check whether the change pushed more "
                  "work at the constraint (wip-accumulation-tree.md).")
    else:
        verdict = "NO MATERIAL CHANGE"
        detail = ("Nothing moved beyond tolerance. Confirm you measured the GLOBAL goal "
                  "metric, not a local stage time (local-optimum-tree.md).")

    print(f"VERDICT: {verdict}")
    print(f"  {detail}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
