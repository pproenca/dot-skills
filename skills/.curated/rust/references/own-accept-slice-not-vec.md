---
title: Accept &[T] Instead of &Vec<T>
impact: CRITICAL
impactDescription: eliminates allocation for array callers
tags: own, slice, vec, borrow, flexibility
---

## Accept &[T] Instead of &Vec<T>

Functions accepting `&[T]` work with `Vec<T>`, arrays `[T; N]`, and slices. Using `&Vec<T>` forces callers to create a Vec even when they have an array.

**Incorrect (requires Vec):**

```rust
fn sum_prices(prices: &Vec<f64>) -> f64 {
    prices.iter().sum()
}

fn main() {
    let prices = [10.0, 20.0, 30.0];  // Array
    sum_prices(&prices.to_vec());  // Forced allocation
}
```

**Correct (accepts any slice-like type):**

```rust
fn sum_prices(prices: &[f64]) -> f64 {
    prices.iter().sum()
}

fn main() {
    let array_prices = [10.0, 20.0, 30.0];
    sum_prices(&array_prices);  // No allocation

    let vec_prices = vec![10.0, 20.0, 30.0];
    sum_prices(&vec_prices);  // Deref coercion, no allocation
}
```

**Also works with:**
- `&[T; N]` (fixed-size arrays)
- `&mut [T]` for mutable slices
- Any type implementing `Deref<Target=[T]>`

Reference: [Rust API Guidelines - C-CALLER-CONTROL](https://rust-lang.github.io/api-guidelines/flexibility.html)
