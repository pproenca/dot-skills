---
title: Prefer Static Dispatch Over Dynamic Dispatch
impact: MEDIUM
impactDescription: enables inlining and eliminates vtable lookup
tags: comp, dispatch, generics, dyn, monomorphization
---

## Prefer Static Dispatch Over Dynamic Dispatch

Generics with trait bounds use static dispatch (monomorphization), which allows inlining. `dyn Trait` uses dynamic dispatch via vtable lookups.

**Incorrect (dynamic dispatch, no inlining):**

```rust
fn process_items(items: &[Box<dyn Processor>]) {
    for item in items {
        item.process();  // vtable lookup each call
    }
}
```

**Correct (static dispatch, enables inlining):**

```rust
fn process_items<P: Processor>(items: &[P]) {
    for item in items {
        item.process();  // Inlined, no vtable lookup
    }
}
```

**When dynamic dispatch IS appropriate:**
- Heterogeneous collections (different types in same container)
- Plugin systems with runtime loading
- Reducing binary size from monomorphization

**Hybrid approach (enum dispatch):**

```rust
enum ProcessorKind {
    Fast(FastProcessor),
    Standard(StandardProcessor),
}

impl Processor for ProcessorKind {
    fn process(&self) {
        match self {
            ProcessorKind::Fast(p) => p.process(),
            ProcessorKind::Standard(p) => p.process(),
        }
    }
}

// Static dispatch via enum, no vtable
fn create_processor(config: &Config) -> ProcessorKind {
    if config.fast_mode {
        ProcessorKind::Fast(FastProcessor::new())
    } else {
        ProcessorKind::Standard(StandardProcessor::new())
    }
}
```

Reference: [Rust Book - Trait Objects](https://doc.rust-lang.org/book/ch17-02-trait-objects.html)
