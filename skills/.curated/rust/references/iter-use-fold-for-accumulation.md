---
title: Use fold() for Complex Accumulation
impact: HIGH
impactDescription: single pass with custom accumulator
tags: iter, fold, reduce, accumulator, aggregation
---

## Use fold() for Complex Accumulation

`fold()` enables complex aggregation in a single pass. It's more flexible than chaining `filter().map().sum()` when you need multiple computed values.

**Incorrect (multiple passes):**

```rust
fn analyze_orders(orders: &[Order]) -> (u32, f64, f64) {
    let count = orders.len() as u32;
    let total: f64 = orders.iter().map(|o| o.amount).sum();
    let max: f64 = orders.iter().map(|o| o.amount).fold(0.0, f64::max);
    (count, total, max)
}
```

**Correct (single pass):**

```rust
fn analyze_orders(orders: &[Order]) -> (u32, f64, f64) {
    orders.iter().fold(
        (0u32, 0.0f64, 0.0f64),
        |(count, total, max), order| {
            (count + 1, total + order.amount, max.max(order.amount))
        },
    )
}
```

**Alternative with try_fold for early exit:**

```rust
fn find_first_invalid(items: &[Item]) -> Result<(), ValidationError> {
    items.iter().try_fold((), |(), item| {
        if item.is_valid() {
            Ok(())
        } else {
            Err(ValidationError::new(item))
        }
    })
}
```

Reference: [Iterator::fold documentation](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.fold)
