#!/usr/bin/env python3
"""Behavior-neutral and construct-changing source transforms used by the harness checks.

  cosmetic <src> <dst>      add comments, blank lines, and trailing whitespace — invisible to a
                            structure metric, visible to LOC (for invariance / anti-gaming).
  grow <src> <dst> [k=50]   append a function with k statements — strictly more construct
                            (for monotonicity).
  ramp <out_dir> n [n...]   write size_<n>.py with n functions each (for tractability timing).

All transforms are deterministic. The fixtures are Python; grow/ramp emit Python.
"""
import os
import sys


def cosmetic(src, dst):
    text = open(src, encoding="utf-8").read()
    noise = (
        "# cosmetic noise added by the harness\n"
        "# a structure metric must ignore this; LOC will not\n\n\n"
    )
    body = "\n".join(line + "   " for line in text.splitlines())  # trailing whitespace
    open(dst, "w", encoding="utf-8").write(noise + body + "\n")


def grow(src, dst, k=50):
    text = open(src, encoding="utf-8").read()
    extra = ["", "", "def _harness_grow():", "    x = 0"]
    extra += ["    x += 1" for _ in range(k)]
    open(dst, "w", encoding="utf-8").write(text.rstrip("\n") + "\n" + "\n".join(extra) + "\n")


def ramp(out_dir, sizes):
    os.makedirs(out_dir, exist_ok=True)
    paths = []
    for n in sizes:
        p = os.path.join(out_dir, f"size_{n}.py")
        with open(p, "w", encoding="utf-8") as f:
            for i in range(n):
                f.write(f"def f{i}(a, b):\n    return a + b + {i}\n\n")
        paths.append(p)
    return paths


def main(argv):
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 1
    cmd = argv[1]
    if cmd == "cosmetic" and len(argv) == 4:
        cosmetic(argv[2], argv[3])
    elif cmd == "grow" and len(argv) in (4, 5):
        grow(argv[2], argv[3], int(argv[4]) if len(argv) == 5 else 50)
    elif cmd == "ramp" and len(argv) >= 4:
        for p in ramp(argv[2], [int(x) for x in argv[3:]]):
            print(p)
    else:
        print(__doc__, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
