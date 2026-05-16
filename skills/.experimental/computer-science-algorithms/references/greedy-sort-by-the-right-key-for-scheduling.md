---
title: Sort By The Right Key — Earliest Deadline, Smallest Ratio, Largest Density
impact: MEDIUM
impactDescription: turns O(n!) brute force into O(n log n) for many scheduling problems
tags: greedy, scheduling, sorting-key, optimization
---

## Sort By The Right Key — Earliest Deadline, Smallest Ratio, Largest Density

A surprisingly large family of scheduling and selection problems is solved by sorting on one specific key, then sweeping. The art is identifying the *right* key. Sorting by start time, by finish time, by duration, by deadline, or by value/weight ratio all give optimal answers for *different* problems — and using the wrong key gives a fast wrong answer. The exchange argument from the previous rule tells you which key is correct.

Cheat sheet of canonical pairings:

| Problem | Sort by |
|---------|---------|
| Activity selection (max count) | Finish time ascending |
| Minimize max lateness | Deadline ascending |
| Fractional knapsack (max value) | Value/weight ratio descending |
| Job sequencing with deadlines | Profit descending (then fit each into latest free slot ≤ deadline) |
| Interval covering | Start time ascending; pick farthest reach |
| Huffman coding | Build from two smallest frequencies repeatedly (priority queue) |

**Incorrect (activity selection sorted by start time — wrong answer):**

```python
def max_activities(intervals: list[tuple[int, int]]) -> int:
    # Sorting by start time is intuitive but wrong: an early-starting,
    # late-finishing interval blocks many shorter ones.
    intervals = sorted(intervals, key=lambda x: x[0])
    count, last_end = 0, -float("inf")
    for s, e in intervals:
        if s >= last_end:
            count += 1; last_end = e
    return count
```

**Correct (sort by finish time):**

```python
def max_activities(intervals: list[tuple[int, int]]) -> int:
    # Earliest finishing time leaves maximum room for the rest.
    intervals = sorted(intervals, key=lambda x: x[1])
    count, last_end = 0, -float("inf")
    for s, e in intervals:
        if s >= last_end:
            count += 1; last_end = e
    return count
```

**Fractional knapsack** (notably *only* the fractional version is greedy — 0/1 needs DP):

```python
def fractional_knapsack(items: list[tuple[int, int]], capacity: int) -> float:
    # items = [(value, weight), ...]
    items = sorted(items, key=lambda x: -x[0] / x[1])  # value-per-weight descending
    total = 0.0
    for v, w in items:
        if capacity >= w:
            total += v; capacity -= w
        else:
            total += v * (capacity / w); break
    return total
```

**Validation step:** after coding, hand-trace a small example. If the greedy produces a worse answer than an obvious alternative, the key (or the algorithm) is wrong.

Reference: [Algorithm Design Manual — Greedy Algorithms (Skiena)](http://www.algorist.com/)
