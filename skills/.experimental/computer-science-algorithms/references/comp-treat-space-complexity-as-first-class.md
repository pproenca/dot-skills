---
title: Treat Space Complexity As First-Class, Not An Afterthought
impact: HIGH
impactDescription: prevents OOM kills at production scale even when time complexity is fine
tags: comp, space-complexity, memory, streaming
---

## Treat Space Complexity As First-Class, Not An Afterthought

Time complexity dominates undergraduate teaching, but in production, space is what kills services: O(n) auxiliary memory at n = 10⁹ exhausts RAM long before time becomes the issue. Worse, allocating O(n) when O(1) exists creates GC pressure, cache misses, and page faults that *also* destroy time performance. Always state the algorithm's space complexity alongside its time complexity, and prefer streaming/iterator forms when consuming large inputs.

For DP, this matters doubly: many DP recurrences only depend on the last 1-2 rows, allowing O(n) space to collapse to O(1) without changing the algorithm.

**Incorrect (materializes the whole input — O(n) memory, OOM on large files):**

```python
def count_long_lines(path: str, min_len: int) -> int:
    # readlines() loads the entire file into a list. For a 10 GB log, this OOMs
    # even though the work is just counting.
    with open(path) as f:
        lines = f.readlines()
    return sum(1 for line in lines if len(line) >= min_len)
```

**Correct (stream — O(1) memory, same O(n) time):**

```python
def count_long_lines(path: str, min_len: int) -> int:
    # Iterating a file yields one line at a time. Constant memory regardless
    # of file size.
    with open(path) as f:
        return sum(1 for line in f if len(line) >= min_len)
```

**DP space reduction example:**

```python
# O(n) space — keeps every row
def fib_full_table(n: int) -> int:
    f = [0] * (n + 1)
    f[1] = 1
    for i in range(2, n + 1):
        f[i] = f[i - 1] + f[i - 2]
    return f[n]

# O(1) space — only keeps the rolling window the recurrence needs
def fib_rolling(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

Reference: [Sedgewick & Wayne — Algorithms 4th ed., §1.4 Analysis](https://algs4.cs.princeton.edu/14analysis/)
