---
title: Preallocate Vec and String Capacity
impact: LOW-MEDIUM
impactDescription: eliminates 2-4 reallocations per collection, reduces allocator pressure
tags: perf, preallocation, vec, string, capacity
---

## Preallocate Vec and String Capacity

Use `Vec::with_capacity(n)` and `String::with_capacity(n)` when the final size is known or can be estimated. Without pre-allocation, each growth doubles the buffer, causing O(log n) allocations and copies. Pre-allocation reduces this to a single allocation.

**Incorrect (starts empty, reallocates as it grows):**

```rust
fn collect_thread_summaries(summaries: &[ThreadSummary]) -> Vec<ThreadInfo> {
    let mut threads = Vec::new();
    for summary in summaries {
        threads.push(ThreadInfo::from(summary));
    }
    threads
}
```

**Correct (single allocation for the known size):**

```rust
fn collect_thread_summaries(summaries: &[ThreadSummary]) -> Vec<ThreadInfo> {
    let mut threads = Vec::with_capacity(summaries.len());
    for summary in summaries {
        threads.push(ThreadInfo::from(summary));
    }
    threads
}
```
