---
title: Reduce Monomorphization Bloat
impact: MEDIUM
impactDescription: smaller binaries, better instruction cache usage
tags: comp, monomorphization, generics, binary-size, cache
---

## Reduce Monomorphization Bloat

Each generic instantiation creates a new copy of the code. Extract non-generic parts to reduce binary size and improve instruction cache usage.

**Incorrect (entire function monomorphized):**

```rust
fn process_data<T: AsRef<[u8]>>(data: T) -> Result<Output, Error> {
    let bytes = data.as_ref();
    // 100 lines of processing that don't depend on T
    validate(bytes)?;
    transform(bytes)?;
    finalize(bytes)
}
```

**Correct (only generic wrapper monomorphized):**

```rust
fn process_data<T: AsRef<[u8]>>(data: T) -> Result<Output, Error> {
    process_data_inner(data.as_ref())  // Thin generic wrapper
}

fn process_data_inner(bytes: &[u8]) -> Result<Output, Error> {
    // 100 lines of processing - single copy in binary
    validate(bytes)?;
    transform(bytes)?;
    finalize(bytes)
}
```

**Common pattern in std:**

```rust
// Vec::push is generic
pub fn push(&mut self, value: T) {
    // Calls non-generic grow logic
    if self.len == self.buf.capacity() {
        self.buf.reserve(1);  // Non-generic
    }
    // ...
}
```

Reference: [The Rust Performance Book - Compile Times](https://nnethercote.github.io/perf-book/compile-times.html)
