#!/usr/bin/env python3
"""Baseline metric: non-blank physical lines of code.

Used by the harness as the discriminant-validity baseline (`valid-discriminant-not-just-loc`).
It is deliberately gameable and NOT comment/whitespace-invariant — point the harness's
invariance check at this command and it will FAIL, which is the lesson.

Adapter contract: take one path argument, print ONE number to stdout.
"""
import sys


def loc(path: str) -> int:
    with open(path, encoding="utf-8") as f:
        return sum(1 for line in f if line.strip())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: metric_loc.py <path>", file=sys.stderr)
        sys.exit(1)
    print(loc(sys.argv[1]))
