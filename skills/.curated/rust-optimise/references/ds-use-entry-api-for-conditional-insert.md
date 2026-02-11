---
title: Use Entry API for Conditional Insert
impact: HIGH
impactDescription: single lookup instead of two
tags: ds, entry, hashmap, insert, conditional
---

## Use Entry API for Conditional Insert

The Entry API performs a single hash lookup for get-or-insert operations. Using `contains_key` followed by `insert` does two lookups.

**Incorrect (two hash lookups):**

```rust
use std::collections::HashMap;

fn count_words(text: &str) -> HashMap<String, u32> {
    let mut counts = HashMap::new();
    for word in text.split_whitespace() {
        if counts.contains_key(word) {  // First lookup
            *counts.get_mut(word).unwrap() += 1;  // Second lookup
        } else {
            counts.insert(word.to_string(), 1);  // Third lookup
        }
    }
    counts
}
```

**Correct (single hash lookup):**

```rust
use std::collections::HashMap;

fn count_words(text: &str) -> HashMap<String, u32> {
    let mut counts = HashMap::new();
    for word in text.split_whitespace() {
        *counts.entry(word.to_string()).or_insert(0) += 1;  // Single lookup
    }
    counts
}
```

**Alternative (avoid allocation when key exists):**

```rust
fn count_words(text: &str) -> HashMap<String, u32> {
    let mut counts = HashMap::new();
    for word in text.split_whitespace() {
        counts
            .entry(word.to_string())
            .and_modify(|c| *c += 1)
            .or_insert(1);
    }
    counts
}
```

Reference: [std::collections::hash_map::Entry documentation](https://doc.rust-lang.org/std/collections/hash_map/enum.Entry.html)
