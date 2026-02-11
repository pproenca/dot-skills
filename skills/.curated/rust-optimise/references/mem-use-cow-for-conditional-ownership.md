---
title: Use Cow for Conditional Ownership
impact: CRITICAL
impactDescription: avoids allocation in read-only path
tags: mem, cow, clone-on-write, allocation, borrow
---

## Use Cow for Conditional Ownership

`Cow` (Clone-on-Write) borrows data when possible and only allocates when mutation is needed. Use it for functions that sometimes need to modify input.

**Incorrect (always allocates):**

```rust
fn normalize_path(path: &str) -> String {
    if path.starts_with("./") {
        path[2..].to_string()  // Allocates
    } else if path.starts_with("/") {
        path.to_string()  // Allocates even when unchanged
    } else {
        format!("./{}", path)  // Allocates
    }
}
```

**Correct (allocates only when needed):**

```rust
use std::borrow::Cow;

fn normalize_path(path: &str) -> Cow<'_, str> {
    if path.starts_with("./") {
        Cow::Borrowed(&path[2..])  // No allocation
    } else if path.starts_with("/") {
        Cow::Borrowed(path)  // No allocation
    } else {
        Cow::Owned(format!("./{}", path))  // Allocates only here
    }
}
```

Callers can use the result directly via `Deref`, or call `.into_owned()` only when they need ownership.

Reference: [Heap Allocations - The Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html)
