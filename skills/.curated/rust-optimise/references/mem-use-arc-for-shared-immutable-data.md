---
title: Use Arc for Shared Immutable Data
impact: CRITICAL
impactDescription: eliminates N clones for N readers
tags: mem, arc, rc, shared, reference-counting
---

## Use Arc for Shared Immutable Data

When multiple owners need read-only access to the same data, use `Arc` (atomic reference counting) instead of cloning. Clone only increments a counter, not the data.

**Incorrect (clones entire config for each handler):**

```rust
fn setup_handlers(config: Config) -> Vec<Handler> {
    let handlers = vec![
        Handler::new(config.clone()),  // Full copy
        Handler::new(config.clone()),  // Full copy
        Handler::new(config.clone()),  // Full copy
    ];
    handlers
}
```

**Correct (shares single allocation):**

```rust
use std::sync::Arc;

fn setup_handlers(config: Config) -> Vec<Handler> {
    let config = Arc::new(config);  // Single allocation
    let handlers = vec![
        Handler::new(Arc::clone(&config)),  // Increments counter
        Handler::new(Arc::clone(&config)),  // Increments counter
        Handler::new(Arc::clone(&config)),  // Increments counter
    ];
    handlers
}
```

**When to use Rc vs Arc:**
- Use `Rc` for single-threaded scenarios (no atomic overhead)
- Use `Arc` when data crosses thread boundaries

Reference: [Heap Allocations - The Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html)
