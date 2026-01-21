---
title: Use Box<dyn Trait> for Runtime Polymorphism
impact: MEDIUM
impactDescription: Trait objects enable runtime polymorphism when types aren't known at compile time
tags: type, trait-objects, box, polymorphism, dynamic-dispatch
---

## Use Box<dyn Trait> for Runtime Polymorphism

Use `Box<dyn Trait>` for trait objects when you need runtime polymorphism - collections of different types implementing the same trait, or when types are determined at runtime.

**Incorrect (problematic pattern):**

```rust
// Trying to use generics where types vary at runtime
struct Advance<S: Store> {
    store: S,  // Type fixed at compile time
}

// Can't have Vec of different store implementations
let stores: Vec<Advance<???>> = vec![
    Advance { store: LocalStore::new() },
    Advance { store: RemoteStore::new() },  // Different type!
];
```

**Correct (recommended pattern):**

```rust
// Trait object for runtime polymorphism
pub struct Advance {
    store: Box<dyn Store + Send + Sync>,
    // Can hold any Store implementation at runtime
}

impl Advance {
    pub fn new_local(path: PathBuf) -> Self {
        Self {
            store: Box::new(LocalStore::new(path)),
        }
    }

    pub fn new_remote(host: &str, port: u16) -> Self {
        Self {
            store: Box::new(RemoteStore::connect(host, port)),
        }
    }
}

// Can now have heterogeneous collections
let stores: Vec<Box<dyn Store>> = vec![
    Box::new(LocalStore::new()),
    Box::new(RemoteStore::new()),
    Box::new(CachedStore::new()),
];

for store in &stores {
    store.get_sample();  // Dynamic dispatch
}
```

```rust
// Common pattern: dyn Trait in struct fields
pub trait ModelStore: Send + Sync {
    type SampleType;
    fn get_sample(&self) -> Option<Self::SampleType>;
}

pub struct Collector {
    stores: Vec<Box<dyn ModelStore<SampleType = Frame>>>,
}
```

**When NOT to use:**
- When all types are known at compile time (use generics)
- Performance-critical hot loops (prefer static dispatch)
- When you need to return the concrete type
