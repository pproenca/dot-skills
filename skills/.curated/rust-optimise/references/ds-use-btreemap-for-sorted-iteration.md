---
title: Use BTreeMap for Sorted Iteration
impact: HIGH
impactDescription: avoids O(n log n) sort after each insertion
tags: ds, btreemap, sorted, ordered, iteration
---

## Use BTreeMap for Sorted Iteration

When you need to iterate over keys in sorted order frequently, use `BTreeMap` instead of `HashMap` followed by sorting.

**Incorrect (sorts on every iteration):**

```rust
use std::collections::HashMap;

fn print_leaderboard(scores: &HashMap<String, u32>) {
    let mut entries: Vec<_> = scores.iter().collect();
    entries.sort_by(|a, b| b.1.cmp(a.1));  // O(n log n) each time

    for (name, score) in entries {
        println!("{}: {}", name, score);
    }
}
```

**Correct (always sorted):**

```rust
use std::collections::BTreeMap;

fn print_leaderboard(scores: &BTreeMap<u32, Vec<String>>) {
    for (score, names) in scores.iter().rev() {  // Already sorted, O(n)
        for name in names {
            println!("{}: {}", name, score);
        }
    }
}
```

**When to use HashMap:**
- Random access is the primary operation
- Order doesn't matter
- Keys are not `Ord`

**When to use BTreeMap:**
- Range queries (`range()` method)
- Sorted iteration is frequent
- Keys implement `Ord`

Reference: [std::collections::BTreeMap documentation](https://doc.rust-lang.org/std/collections/struct.BTreeMap.html)
