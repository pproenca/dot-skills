---
title: Use Turbofish for Explicit collect Type
impact: LOW-MEDIUM
impactDescription: makes collection type explicit, avoids type inference errors
tags: iter, collect, turbofish, type-annotation, inference
---

## Use Turbofish for Explicit collect Type

Use turbofish (`::<>`) syntax with `collect()` to specify the target collection type explicitly. This avoids type inference ambiguity.

**Incorrect (relies on later usage for inference):**

```rust
fn process_numbers(input: &str) {
    let numbers = input.split(',')
        .map(|s| s.trim().parse().unwrap())
        .collect();  // Type unclear until used

    // Much later...
    let first: i32 = numbers[0];  // Only here does type become clear
}
```

**Correct (explicit turbofish):**

```rust
fn process_numbers(input: &str) {
    let numbers: Vec<i32> = input.split(',')
        .map(|s| s.trim().parse().unwrap())
        .collect();

    // Or with turbofish on collect
    let numbers = input.split(',')
        .map(|s| s.trim().parse::<i32>().unwrap())
        .collect::<Vec<_>>();

    // For HashSet
    let unique = input.split(',')
        .map(|s| s.trim())
        .collect::<HashSet<_>>();
}
```

**Common collect targets:**

```rust
// Vec
let v = iter.collect::<Vec<_>>();

// String from chars
let s = chars.collect::<String>();

// HashMap from pairs
let m = pairs.collect::<HashMap<_, _>>();

// Result<Vec<T>, E> from Vec<Result<T, E>>
let results = iter.collect::<Result<Vec<_>, _>>()?;
```

**Note:** `_` lets the compiler infer the element type while you specify the container type.

Reference: [Iterator::collect - Rust Standard Library](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect)
