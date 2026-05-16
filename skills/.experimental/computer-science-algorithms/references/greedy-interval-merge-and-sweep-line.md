---
title: Use Sweep-Line For Interval Overlap And Maximum-Concurrency Problems
impact: MEDIUM
impactDescription: O(n²) pairwise checks to O(n log n) sort + linear sweep
tags: greedy, sweep-line, intervals, events
---

## Use Sweep-Line For Interval Overlap And Maximum-Concurrency Problems

For any problem of the form "given a set of intervals, find X" — merge overlapping intervals, find the maximum number of overlapping intervals at any point, find the smallest set of points hitting every interval, allocate the minimum number of rooms — the canonical technique is **sweep-line**: convert each interval into two events (start, end), sort the events, sweep left-to-right while maintaining a counter or priority queue. Total work is O(n log n) for the sort plus O(n) for the sweep.

The naive O(n²) check-every-pair approach works only up to n ≈ 10⁴. Sweep-line scales to 10⁷.

**Incorrect (pairwise overlap check — O(n²)):**

```python
def max_overlap(intervals: list[tuple[int, int]]) -> int:
    # For every point that matters, count how many intervals cover it. O(n²).
    points = sorted({p for s, e in intervals for p in (s, e)})
    return max(sum(1 for s, e in intervals if s <= p < e) for p in points)
```

**Correct (sweep-line — O(n log n)):**

```python
def max_overlap(intervals: list[tuple[int, int]]) -> int:
    # Each interval contributes two events: +1 at start, -1 at end.
    # Sort by time; ties: end before start so [1,3) and [3,5) don't overlap at 3.
    events = []
    for s, e in intervals:
        events.append((s, +1))
        events.append((e, -1))
    events.sort()
    current = peak = 0
    for _, delta in events:
        current += delta
        peak = max(peak, current)
    return peak
```

**Merge overlapping intervals** (sort by start, merge greedily):

```python
def merge_intervals(intervals: list[tuple[int, int]]) -> list[tuple[int, int]]:
    if not intervals: return []
    intervals = sorted(intervals)
    merged = [intervals[0]]
    for s, e in intervals[1:]:
        last_s, last_e = merged[-1]
        if s <= last_e:                    # overlap (or touch)
            merged[-1] = (last_s, max(last_e, e))
        else:
            merged.append((s, e))
    return merged
```

**Minimum rooms / meeting scheduler** (heap of end times):

```python
import heapq

def min_rooms(intervals: list[tuple[int, int]]) -> int:
    intervals = sorted(intervals)
    end_heap: list[int] = []
    for s, e in intervals:
        if end_heap and end_heap[0] <= s:
            heapq.heapreplace(end_heap, e)  # reuse a room
        else:
            heapq.heappush(end_heap, e)
    return len(end_heap)
```

**The sweep-line skeleton generalizes to 2D**: rectangle area union (sweep + segment tree), line-segment intersection (Bentley-Ottmann), and closest pair of points.

Reference: [cp-algorithms — Sweep line algorithms](https://cp-algorithms.com/geometry/intersecting_segments.html)
