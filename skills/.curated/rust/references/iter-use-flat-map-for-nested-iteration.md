---
title: Use flat_map for Nested Iteration
impact: HIGH
impactDescription: avoids nested loops and intermediate collections
tags: iter, flat_map, flatten, nested, iteration
---

## Use flat_map for Nested Iteration

`flat_map` combines map and flatten into a single operation, avoiding nested loops and intermediate allocations.

**Incorrect (nested loops with intermediate Vec):**

```rust
fn get_all_tags(posts: &[Post]) -> Vec<String> {
    let mut all_tags = Vec::new();
    for post in posts {
        for tag in &post.tags {
            all_tags.push(tag.clone());
        }
    }
    all_tags
}
```

**Correct (flat_map):**

```rust
fn get_all_tags(posts: &[Post]) -> Vec<String> {
    posts
        .iter()
        .flat_map(|post| post.tags.iter().cloned())
        .collect()
}
```

**Alternative with flatten:**

```rust
fn get_all_tags(posts: &[Post]) -> Vec<String> {
    posts
        .iter()
        .map(|post| post.tags.iter().cloned())
        .flatten()
        .collect()
}
```

`flat_map(f)` is equivalent to `map(f).flatten()` but more idiomatic.

Reference: [Iterator::flat_map documentation](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.flat_map)
