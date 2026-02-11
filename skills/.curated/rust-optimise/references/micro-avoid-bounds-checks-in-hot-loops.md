---
title: Avoid Bounds Checks in Hot Loops
impact: LOW
impactDescription: eliminates branch per iteration
tags: micro, bounds-check, unsafe, iterator, hot-loop
---

## Avoid Bounds Checks in Hot Loops

Array indexing in Rust includes bounds checks. In hot loops where bounds are provably safe, use iterators or `get_unchecked` to eliminate checks.

**Incorrect (bounds check per iteration):**

```rust
fn sum_array(arr: &[i32]) -> i32 {
    let mut sum = 0;
    for i in 0..arr.len() {
        sum += arr[i];  // Bounds check each iteration
    }
    sum
}
```

**Correct (iterator, no bounds checks):**

```rust
fn sum_array(arr: &[i32]) -> i32 {
    arr.iter().sum()  // No bounds checks, SIMD-friendly
}
```

**Alternative (unsafe for proven bounds):**

```rust
fn process_pairs(arr: &[i32]) -> i32 {
    let mut sum = 0;
    for i in 0..arr.len() / 2 {
        // SAFETY: i * 2 + 1 < arr.len() because i < arr.len() / 2
        unsafe {
            sum += arr.get_unchecked(i * 2) + arr.get_unchecked(i * 2 + 1);
        }
    }
    sum
}
```

**Prefer safe alternatives:**
- Use iterators (`iter()`, `chunks()`, `windows()`)
- Use `split_at()` to partition safely
- Reserve `get_unchecked` for proven hot paths

Reference: [The Rust Performance Book - Bounds Checks](https://nnethercote.github.io/perf-book/bounds-checks.html)
