---
title: Use const for Compile-Time Computation
impact: MEDIUM
impactDescription: eliminates runtime computation entirely
tags: comp, const, compile-time, constant, evaluation
---

## Use const for Compile-Time Computation

Mark values as `const` when they can be computed at compile time. This eliminates runtime computation and enables further optimizations.

**Incorrect (computed at runtime):**

```rust
fn get_buffer_size() -> usize {
    4 * 1024 * 1024  // Computed every call
}

fn create_buffer() -> Vec<u8> {
    Vec::with_capacity(get_buffer_size())
}
```

**Correct (computed at compile time):**

```rust
const BUFFER_SIZE: usize = 4 * 1024 * 1024;  // Computed once at compile time

fn create_buffer() -> Vec<u8> {
    Vec::with_capacity(BUFFER_SIZE)
}
```

**const functions for complex computation:**

```rust
const fn calculate_hash_table_size(expected_items: usize) -> usize {
    // Load factor of 0.75
    (expected_items * 4) / 3 + 1
}

const HASH_TABLE_SIZE: usize = calculate_hash_table_size(1000);
```

**Benefits:**
- Zero runtime overhead
- Values available for array sizes
- Enables compiler optimizations

Reference: [Rust Reference - Constant Items](https://doc.rust-lang.org/reference/items/constant-items.html)
