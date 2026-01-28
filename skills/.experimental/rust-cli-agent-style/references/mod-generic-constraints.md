---
title: Use where clauses for complex bounds
impact: MEDIUM
impactDescription: Where clauses improve readability of complex generic constraints
tags: mod, generics, constraints
---

# Use where clauses for complex bounds

Move complex generic bounds to where clauses for readability.

## Why This Matters

- Function signatures stay clean
- Complex bounds are readable
- Easier to modify constraints
- Better formatted by rustfmt

**Incorrect (avoid this pattern):**

```rust
// Hard to read - bounds inline
fn process<T: Debug + Clone + Send + Sync + 'static, E: Error + Send>(
    data: T,
    handler: impl Fn(T) -> Result<(), E>,
) -> Result<(), E> {
    // ...
}

// Long struct definition
pub struct Handler<T: Clone + Send + Sync + 'static, S: AsyncRead + AsyncWrite + Unpin> {
    data: T,
    stream: S,
}
```

**Correct (recommended):**

```rust
// Clean signature with where clause
fn process<T, E>(
    data: T,
    handler: impl Fn(T) -> Result<(), E>,
) -> Result<(), E>
where
    T: Debug + Clone + Send + Sync + 'static,
    E: Error + Send,
{
    // ...
}

// Struct with where clause
pub struct Handler<T, S>
where
    T: Clone + Send + Sync + 'static,
    S: AsyncRead + AsyncWrite + Unpin,
{
    data: T,
    stream: S,
}

impl<T, S> Handler<T, S>
where
    T: Clone + Send + Sync + 'static,
    S: AsyncRead + AsyncWrite + Unpin,
{
    pub fn new(data: T, stream: S) -> Self {
        Self { data, stream }
    }
}
```

## When to Use Inline vs Where

**Inline bounds** (short):
```rust
fn clone_it<T: Clone>(x: T) -> T { x.clone() }
```

**Where clause** (complex):
```rust
fn complex<T, U>(x: T, y: U)
where
    T: Clone + Debug + Send,
    U: From<T> + Default,
{
    // ...
}
```
