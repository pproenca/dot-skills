---
title: Replace Pairwise Loops With Hash-Based Single Passes
impact: CRITICAL
impactDescription: O(n²) to O(n) — 100× faster at n=10,000
tags: nested, quadratic, hash-set, deduplication, single-pass
---

## Replace Pairwise Loops With Hash-Based Single Passes

Two nested loops over the same collection — even when the inner loop starts at `i+1` — produce O(n²) work. At n=10,000 that's 100 million comparisons; at n=1,000,000 it's a trillion. The pattern is almost always avoidable by passing through the data once and remembering what was seen in a hash set or map. The key insight: "have I seen X before?" is an O(1) question when you maintain the right index, not an O(n) re-scan.

**Incorrect (pairwise comparison — O(n²)):**

```python
duplicates = set()
for i, a in enumerate(items):
    for j, b in enumerate(items):
        if i != j and a == b:
            duplicates.add(a)
# 10,000 items → 100,000,000 iterations, ~seconds of CPU
```

**Correct (single pass with a set — O(n)):**

```python
seen = set()
duplicates = set()
for item in items:
    if item in seen:        # O(1) lookup
        duplicates.add(item)
    seen.add(item)
# 10,000 items → 10,000 iterations, ~milliseconds
```

**When NOT to use this pattern:**
- When `n` is provably tiny (< ~30) and bounded — the hash overhead may dominate, and a nested loop is clearer.
- When the comparison requires fuzzy matching (similarity, distance) where no hash key applies — consider blocking, LSH, or a spatial index instead.

Reference: [Python Time Complexity — set lookup is O(1) amortized](https://wiki.python.org/moin/TimeComplexity)
