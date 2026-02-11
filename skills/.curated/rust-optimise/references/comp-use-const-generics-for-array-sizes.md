---
title: Use Const Generics for Array Sizes
impact: MEDIUM
impactDescription: eliminates runtime bounds checks
tags: comp, const-generics, array, size, compile-time
---

## Use Const Generics for Array Sizes

Const generics allow arrays of different sizes to be handled generically while keeping the size known at compile time.

**Incorrect (loses size information):**

```rust
fn process_buffer(buffer: &[u8]) -> u8 {
    // Can't verify size at compile time
    assert_eq!(buffer.len(), 16);  // Runtime check
    buffer[0] ^ buffer[15]
}
```

**Correct (compile-time size guarantee):**

```rust
fn process_buffer<const N: usize>(buffer: &[u8; N]) -> u8
where
    [(); N - 16]: ,  // Compile error if N < 16
{
    buffer[0] ^ buffer[N - 1]
}

fn main() {
    let small = [0u8; 16];
    let large = [0u8; 32];
    process_buffer(&small);  // OK
    process_buffer(&large);  // OK
    // process_buffer(&[0u8; 8]);  // Compile error
}
```

**For fixed-size chunks:**

```rust
fn hash_blocks<const BLOCK_SIZE: usize>(data: &[[u8; BLOCK_SIZE]]) -> u64 {
    data.iter().fold(0u64, |acc, block| {
        acc.wrapping_add(hash_block(block))
    })
}
```

Reference: [Rust Reference - Const Generics](https://doc.rust-lang.org/reference/items/generics.html#const-generics)
