---
title: Avoid Collecting Then Iterating
impact: LOW-MEDIUM
impactDescription: eliminates intermediate allocation, enables lazy evaluation
tags: iter, collect, allocation, lazy, performance
---

## Avoid Collecting Then Iterating

Don't collect into a Vec just to iterate again. Keep the iterator chain lazy until the final operation.

**Incorrect (unnecessary intermediate collection):**

```rust
fn process_logs(logs: &[LogEntry]) -> usize {
    let errors: Vec<&LogEntry> = logs.iter()
        .filter(|l| l.level == Level::Error)
        .collect();  // Allocates Vec

    let recent: Vec<&LogEntry> = errors.iter()
        .filter(|l| l.timestamp > cutoff)
        .copied()
        .collect();  // Another allocation

    recent.len()  // Just counting!
}
```

**Correct (keep iterator lazy):**

```rust
fn process_logs(logs: &[LogEntry]) -> usize {
    logs.iter()
        .filter(|l| l.level == Level::Error)
        .filter(|l| l.timestamp > cutoff)
        .count()  // No intermediate allocations
}
```

**When collect is needed:**
- Need to iterate multiple times
- Need random access to results
- Need to store results for later use

**When to keep lazy:**
- Single-pass operations (count, sum, any, all, find)
- Chaining more transformations
- Result is immediately consumed

**Use itertools for more power:**

```rust
use itertools::Itertools;

// Unique without collecting
iter.unique().for_each(|x| println!("{}", x));

// Sorted chunks without full collection
iter.sorted().chunks(10)
```

Reference: [Iterator - Rust Standard Library](https://doc.rust-lang.org/std/iter/trait.Iterator.html)
