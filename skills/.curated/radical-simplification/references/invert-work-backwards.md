---
title: Work backwards from the goal when forward search exhausts
tags: invert, polya, backward-search
---

## Work backwards from the goal when forward search exhausts

The default is forward search: take the current state and explore outward. When the state space is large and the goal is narrow, this is exponentially harder than the reverse. Working backwards from the goal — what must be true one step before the goal? two steps before? — narrows the search to states that *could* reach it, and often makes the path obvious.

```text
Goal: checkout p99 latency < 200ms. Currently 480ms.

Forward search (the default trap):
  Profile, find the slowest line, optimize it, re-measure, repeat.
  Often shaves 50ms over a week and stalls.

Backwards search:
  Budget the 200ms across the layers it must pass through:
    DB queries     80ms
    app logic      40ms
    network RTT    40ms
    template render 40ms
                  ────
                  200ms

  Measure each layer against its budget:
    DB queries    320ms  ← 4× over
    app logic      30ms  ✓
    network RTT    50ms  slightly over
    template       80ms  2× over

  The over-budget items name themselves; the search collapses
  from "everything" to "DB and templates".
```

This is Pólya's "What must be true just before the goal?" applied to engineering. The forward agent asks "what can I do next?" — combinatorial. The backward agent asks "what *must* have been true one step before success?" — usually unique or near-unique.

Reference: [Pólya — How to Solve It, "Working Backwards"](https://en.wikipedia.org/wiki/How_to_Solve_It)
