---
title: Replace index loops and mut accumulators with iterator chains
tags: iter, iterators, combinators, loops
---

## Replace index loops and mut accumulators with iterator chains

`for i in 0..items.len()` with `items[i]`, and `let mut result = Vec::new()` + push inside an `if`, are C/Python transliterations: they re-implement `filter`, `map`, and `sum` by hand, pay a bounds check per index, and force the reader to reverse-engineer the transformation from loop mechanics. The named combinator *states* the transformation, borrows correctly by construction, and compiles to the same or better code — iterators are one of Rust's documented zero-cost abstractions.

**Incorrect (the reader simulates the loop to learn it's a filter-map):**

```rust
let mut refunds = Vec::new();
for i in 0..orders.len() {
    if orders[i].status == Status::Returned {
        refunds.push(orders[i].total * REFUND_RATE);
    }
}
```

**Correct (the transformation, named):**

```rust
let refunds: Vec<Cents> = orders
    .iter()
    .filter(|o| o.status == Status::Returned)
    .map(|o| o.total * REFUND_RATE)
    .collect();
```

**When a loop IS right:** early exit with side effects, mutating in place across multiple bindings, or genuinely index-coupled access (windows over two arrays — though check `zip`/`windows`/`chunks` first). A plain `for item in &items` is fine; the smell is *indices and accumulators* re-deriving a named combinator.

Reference: [The Rust Book — Comparing Performance: Loops vs. Iterators](https://doc.rust-lang.org/book/ch13-04-performance.html)
