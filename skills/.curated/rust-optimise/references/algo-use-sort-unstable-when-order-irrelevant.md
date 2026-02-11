---
title: Use sort_unstable When Order of Equal Elements Is Irrelevant
impact: MEDIUM
impactDescription: 10-30% faster sorting
tags: algo, sort, unstable, stable, performance
---

## Use sort_unstable When Order of Equal Elements Is Irrelevant

`sort_unstable()` is faster than `sort()` because it doesn't preserve the relative order of equal elements. Use it when this order doesn't matter.

**Incorrect (stable sort when not needed):**

```rust
fn get_sorted_scores(mut scores: Vec<u32>) -> Vec<u32> {
    scores.sort();  // Preserves order of equal elements, slower
    scores
}
```

**Correct (unstable sort):**

```rust
fn get_sorted_scores(mut scores: Vec<u32>) -> Vec<u32> {
    scores.sort_unstable();  // Faster, doesn't preserve equal element order
    scores
}
```

**When stable sort IS needed:**

```rust
#[derive(Clone)]
struct Player {
    name: String,
    score: u32,
}

fn rank_players(mut players: Vec<Player>) -> Vec<Player> {
    // Stable sort preserves original order for tied scores
    players.sort_by_key(|p| std::cmp::Reverse(p.score));
    players
}
```

**Performance difference:**
- `sort_unstable` is O(n log n) with better constants
- `sort` needs additional memory for stability

Reference: [slice::sort_unstable documentation](https://doc.rust-lang.org/std/primitive.slice.html#method.sort_unstable)
