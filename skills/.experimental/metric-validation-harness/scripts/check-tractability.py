#!/usr/bin/env python3
"""check-tractability — the metric must scale near-linearly, not blow up (comp-keep-the-metric-tractable).

Generates inputs of increasing size, times the metric on each (best of 3), and fails if the
largest input exceeds a wall-clock budget or the least-squares log-log growth exponent is
super-quadratic. The wall-clock budget is the primary backstop; at small sizes the slope is
dampened by process-spawn overhead, so treat this as a blowup smoke test, not a microbenchmark
(profile your metric directly on production-sized inputs for real numbers).
"""
import math
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))
import harness  # noqa: E402

SIZES = [100, 200, 400, 800, 1600]
BUDGET_SECONDS = float(os.environ.get("TRACTABILITY_BUDGET", "10.0"))
MAX_SLOPE = float(os.environ.get("TRACTABILITY_MAX_SLOPE", "2.2"))  # log-log exponent; <2 is sub-quadratic


def lstsq_slope(xs, ys):
    """Least-squares slope of ys vs xs (more robust than two-point endpoints)."""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    den = sum((x - mx) ** 2 for x in xs)
    if den == 0:
        return 0.0
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / den


def main():
    cmd = harness.metric_cmd()
    tmp = tempfile.mkdtemp()
    try:
        subprocess.run(
            [sys.executable, os.path.join(HERE, "lib", "transforms.py"), "ramp", tmp, *map(str, SIZES)],
            check=True, capture_output=True,
        )
        times = []
        for n in SIZES:
            path = os.path.join(tmp, f"size_{n}.py")
            t = min(harness.timed_metric(cmd, path) for _ in range(3))
            times.append(max(t, 1e-6))
            print(f"  size {n:>4} funcs: {t * 1000:7.1f} ms")

        fails = 0
        if times[-1] > BUDGET_SECONDS:
            print(f"FAIL: largest input took {times[-1]:.2f}s (> {BUDGET_SECONDS}s budget)")
            fails += 1

        slope = lstsq_slope([math.log(n) for n in SIZES], [math.log(t) for t in times])
        if slope > MAX_SLOPE:
            print(f"FAIL: least-squares exponent ~{slope:.2f} (> {MAX_SLOPE}); the metric looks super-quadratic")
            fails += 1
        else:
            print(f"PASS: least-squares exponent ~{slope:.2f} (<= {MAX_SLOPE}); largest input within budget")

        print(f"check-tractability: {'0 failed' if fails == 0 else f'{fails} failed'}")
        return 1 if fails else 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
