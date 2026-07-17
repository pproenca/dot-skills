---
title: Use match statements for type-and-shape ladders
tags: disp, match, pattern-matching, isinstance
---

## Use match statements for type-and-shape ladders

Requires Python ≥ 3.10 (PEP 634 structural pattern matching).

Code that checks a value's type, then its length or keys, then indexes into it
re-implements what structural pattern matching does in one pattern — check,
destructure, and bind together. The pre-3.10 habit produces nested
`isinstance`/`len`/`"key" in d` ladders followed by manual `x[0]`/`d["key"]`
access that can drift out of sync with the checks above it. `match` narrows and
binds atomically, and `case _` makes the unhandled shape a deliberate decision
instead of a fall-through.

**Incorrect (checks and access drift apart):**

```python
def normalize_point(raw: object) -> Point:
    if isinstance(raw, dict) and "x" in raw and "y" in raw:
        return Point(raw["x"], raw["y"])
    elif isinstance(raw, (list, tuple)) and len(raw) == 2:
        return Point(raw[0], raw[1])
    elif isinstance(raw, Point):
        return raw
    raise ValueError(f"unrecognized point shape: {raw!r}")
```

**Correct (one pattern checks, destructures, and binds):**

```python
def normalize_point(raw: object) -> Point:
    match raw:
        case {"x": x, "y": y}:
            return Point(x, y)
        case [x, y] | (x, y):
            return Point(x, y)
        case Point():
            return raw
        case _:
            raise ValueError(f"unrecognized point shape: {raw!r}")
```

**Evidence of violation:** a branch ladder with **2 or more levels** of
combined type-then-shape inspection — `isinstance`/`hasattr` plus
`len(...)`/`in`-key checks — followed by manual element access
(`x[0]`, `d["key"]`) on the value just checked, in a target whose Python floor
is ≥ 3.10. PASS: the same logic expressed as `match` with mapping/sequence/class
patterns, or the input is normalized to a declared type at the boundary so no
ladder exists — cite the construct. N/A: Python floor < 3.10, single
`isinstance` guards with no shape destructuring, or `isinstance` used for
narrowing alone without element access.

Reference: [PEP 634 — Structural Pattern Matching (What's New in Python 3.10)](https://docs.python.org/3/whatsnew/3.10.html#pep-634-structural-pattern-matching)
