---
title: Use select_nth_unstable for Partial Sorting
impact: MEDIUM
impactDescription: O(n log n) to O(n) for finding kth element
tags: algo, select, partial-sort, median, quickselect
---

## Use select_nth_unstable for Partial Sorting

When you only need the kth smallest element (not a fully sorted array), `select_nth_unstable` is O(n) vs O(n log n) for full sorting.

**Incorrect (full sort for median):**

```rust
fn find_median(mut values: Vec<i32>) -> i32 {
    values.sort();  // O(n log n)
    values[values.len() / 2]
}
```

**Correct (partial sort):**

```rust
fn find_median(mut values: Vec<i32>) -> i32 {
    let mid = values.len() / 2;
    values.select_nth_unstable(mid);  // O(n) on average
    values[mid]
}
```

**For top-k elements:**

```rust
fn top_k_scores(mut scores: Vec<u32>, k: usize) -> Vec<u32> {
    if k >= scores.len() {
        scores.sort_unstable_by(|a, b| b.cmp(a));
        return scores;
    }
    scores.select_nth_unstable_by(k, |a, b| b.cmp(a));  // O(n)
    scores.truncate(k);
    scores.sort_unstable_by(|a, b| b.cmp(a));  // O(k log k)
    scores
}
```

**Use cases:**
- Finding median
- Top-k / bottom-k queries
- Percentile calculations

Reference: [slice::select_nth_unstable documentation](https://doc.rust-lang.org/std/primitive.slice.html#method.select_nth_unstable)
