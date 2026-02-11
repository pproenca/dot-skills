---
title: Use Wrapping Arithmetic When Overflow Is Expected
impact: LOW
impactDescription: eliminates overflow check overhead
tags: micro, wrapping, overflow, arithmetic, hash
---

## Use Wrapping Arithmetic When Overflow Is Expected

Standard arithmetic in debug mode panics on overflow. For intentional wrapping (hashing, checksums), use `wrapping_*` methods.

**Incorrect (overflow panic in debug, UB potential):**

```rust
fn simple_hash(bytes: &[u8]) -> u64 {
    let mut hash = 0u64;
    for &byte in bytes {
        hash = hash * 31 + byte as u64;  // May panic in debug mode
    }
    hash
}
```

**Correct (explicit wrapping):**

```rust
fn simple_hash(bytes: &[u8]) -> u64 {
    let mut hash = 0u64;
    for &byte in bytes {
        hash = hash.wrapping_mul(31).wrapping_add(byte as u64);
    }
    hash
}
```

**Using Wrapping type:**

```rust
use std::num::Wrapping;

fn simple_hash(bytes: &[u8]) -> u64 {
    let mut hash = Wrapping(0u64);
    for &byte in bytes {
        hash = hash * Wrapping(31) + Wrapping(byte as u64);
    }
    hash.0
}
```

**Arithmetic variants:**
- `wrapping_*`: Wraps on overflow
- `saturating_*`: Clamps to min/max
- `checked_*`: Returns Option
- `overflowing_*`: Returns (result, overflowed)

Reference: [std::num module documentation](https://doc.rust-lang.org/std/num/)
