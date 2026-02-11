---
title: Avoid Nested Loops for Lookups
impact: MEDIUM
impactDescription: O(n×m) to O(n+m)
tags: algo, nested-loop, complexity, hashset, optimization
---

## Avoid Nested Loops for Lookups

Nested loops for matching elements between collections are O(n×m). Convert the inner collection to a HashSet for O(n+m).

**Incorrect (O(n×m)):**

```rust
fn find_common_ids(list_a: &[u64], list_b: &[u64]) -> Vec<u64> {
    let mut common = Vec::new();
    for id_a in list_a {
        for id_b in list_b {  // O(m) per element of list_a
            if id_a == id_b {
                common.push(*id_a);
            }
        }
    }
    common
}
```

**Correct (O(n+m)):**

```rust
use std::collections::HashSet;

fn find_common_ids(list_a: &[u64], list_b: &[u64]) -> Vec<u64> {
    let set_b: HashSet<_> = list_b.iter().collect();  // O(m)
    list_a
        .iter()
        .filter(|id| set_b.contains(id))  // O(1) per check
        .copied()
        .collect()
}
```

**With built-in set intersection:**

```rust
fn find_common_ids(list_a: &[u64], list_b: &[u64]) -> Vec<u64> {
    let set_a: HashSet<_> = list_a.iter().collect();
    let set_b: HashSet<_> = list_b.iter().collect();
    set_a.intersection(&set_b).copied().collect()
}
```

Reference: [std::collections::HashSet::intersection](https://doc.rust-lang.org/std/collections/struct.HashSet.html#method.intersection)
