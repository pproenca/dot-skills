---
title: Reason About Amortized Cost, Not Just Worst-Case Per Operation
impact: CRITICAL
impactDescription: prevents discarding O(1) amortized structures (dynamic arrays, hash tables) for false O(n) fears
tags: comp, amortized-analysis, dynamic-array, hash-table
---

## Reason About Amortized Cost, Not Just Worst-Case Per Operation

Many fundamental data structures rely on amortized analysis: each individual operation may occasionally be expensive, but the average cost across a sequence is bounded. Dynamic array `append`, hash-table `insert`, and union-find with path compression all look "bad" if you only inspect their worst case. Misreading those costs leads engineers to swap a perfectly good O(n) algorithm for a hand-rolled linked-list version that's measurably slower.

The rule: when bounding *total* work over many operations, use amortized cost. Use worst-case per operation only when a single slow operation would violate a latency SLO.

**Incorrect (rejecting `list.append` because "resizing is O(n)"):**

```python
# Author worries that occasional resize makes appends O(n) worst case
# and switches to a linked list to "guarantee O(1) per append".
class Node:
    __slots__ = ("val", "next")
    def __init__(self, val):
        self.val, self.next = val, None

def build(values: list[int]):
    # O(1) "guaranteed" — but constant factor is huge, and traversal is now O(n) per access.
    head = tail = None
    for v in values:
        node = Node(v)
        if tail is None:
            head = tail = node
        else:
            tail.next = node
            tail = node
    return head
```

**Correct (use the dynamic array — amortized O(1) append, contiguous memory):**

```python
def build(values: list[int]) -> list[int]:
    # Amortized O(1) per append: resizes double capacity, so total resize work
    # across n appends is O(n). Net: O(n) total, O(1) amortized per op.
    # Contiguous storage gives ~10x better iteration speed via cache locality.
    return list(values)
```

**When worst-case matters more than amortized:**

- Hard real-time systems (audio, robotics) where any spike is unacceptable
- Latency-sensitive request paths with strict p99 budgets — one O(n) rehash can blow p99 even if amortized is O(1)
- In those cases, prefer pre-sized structures (`dict.fromkeys(...)` with known capacity, `list` with `[None] * n` pre-allocation)

Reference: [CLRS Chapter 17 — Amortized Analysis](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
