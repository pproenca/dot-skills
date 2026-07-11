---
title: Stay lazy — collect once at the end of the chain
tags: iter, laziness, collect, allocation
---

## Stay lazy — collect once at the end of the chain

Calling `.collect::<Vec<_>>()` after each step and re-iterating the result treats iterator stages like eager pipeline steps in Python or JavaScript arrays. Rust iterators are lazy — adapters fuse into a single pass — so each intermediate `collect` buys a full allocation and traversal that the fused chain would never perform. Keep the chain lazy end to end and materialize once, or not at all when the consumer is `sum`/`any`/`for`.

**Incorrect (three passes, two throwaway Vecs):**

```rust
let active: Vec<&Account> = accounts.iter().filter(|a| a.active).collect();
let balances: Vec<Cents> = active.iter().map(|a| a.balance).collect();
let total: Cents = balances.iter().copied().sum();
```

**Correct (one fused pass, zero intermediate allocation):**

```rust
let total: Cents = accounts
    .iter()
    .filter(|a| a.active)
    .map(|a| a.balance)
    .sum();
```

**When an intermediate collect IS right:** the midpoint is reused several times, the chain needs `.sort()` (sorting requires a materialized slice), or collecting into `Result<Vec<_>, E>` to stop at the first error.

Reference: [std::iter — Laziness](https://doc.rust-lang.org/std/iter/index.html#laziness)
