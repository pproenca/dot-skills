---
title: Use Binary Search for Sorted Data
impact: MEDIUM
impactDescription: O(n) to O(log n)
tags: algo, binary-search, sorted, search, complexity
---

## Use Binary Search for Sorted Data

When searching sorted data, use `binary_search()` instead of linear search. It's O(log n) vs O(n).

**Incorrect (linear search):**

```rust
fn find_threshold_index(sorted_values: &[i32], threshold: i32) -> Option<usize> {
    sorted_values.iter().position(|&v| v >= threshold)  // O(n)
}
```

**Correct (binary search):**

```rust
fn find_threshold_index(sorted_values: &[i32], threshold: i32) -> Option<usize> {
    match sorted_values.binary_search(&threshold) {
        Ok(idx) => Some(idx),           // Exact match
        Err(idx) => Some(idx).filter(|&i| i < sorted_values.len()),  // Insertion point
    }
}
```

**For partition point (first element matching condition):**

```rust
fn find_threshold_index(sorted_values: &[i32], threshold: i32) -> usize {
    sorted_values.partition_point(|&v| v < threshold)  // O(log n)
}
```

**When to use which:**
- `binary_search`: Find exact value
- `partition_point`: Find first element matching condition
- `binary_search_by`: Custom comparison function

Reference: [slice::binary_search documentation](https://doc.rust-lang.org/std/primitive.slice.html#method.binary_search)
