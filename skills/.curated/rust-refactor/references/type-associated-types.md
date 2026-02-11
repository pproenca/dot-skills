---
title: Use Associated Types for Related Type Relationships
impact: HIGH
impactDescription: Associated types simplify trait bounds and make APIs more ergonomic
tags: type, traits, associated-types, generics
---

## Use Associated Types for Related Type Relationships

Traits with related types should use associated types rather than generic parameters. This simplifies usage and makes the relationship explicit.

**Incorrect (problematic pattern):**

```rust
// Generic parameter - verbose and allows multiple impls
trait Store<SampleType, ModelType> {
    fn get_sample(&self) -> Option<SampleType>;
    fn get_model(&self) -> Option<ModelType>;
}

// Users must specify types everywhere
fn process<S, M, St: Store<S, M>>(store: St) { ... }

// Confusing: same type can implement Store multiple ways
impl Store<FrameA, ModelA> for MyStore { ... }
impl Store<FrameB, ModelB> for MyStore { ... }  // Ambiguous
```

**Correct (recommended pattern):**

```rust
// Associated types - one implementation per type
trait Store {
    type SampleType;
    type ModelType;

    fn get_sample(&self) -> Option<Self::SampleType>;
    fn get_model(&self) -> Option<Self::ModelType>;
}

impl Store for LocalStore {
    type SampleType = DataFrame;
    type ModelType = Model;

    fn get_sample(&self) -> Option<Self::SampleType> { ... }
    fn get_model(&self) -> Option<Self::ModelType> { ... }
}

// Clean usage
fn process<St: Store>(store: St) {
    let sample: Option<St::SampleType> = store.get_sample();
}

// Or with where clause for bounds on associated type
fn process_numeric<St>(store: St)
where
    St: Store,
    St::SampleType: Into<u64>,
{ ... }
```

**When NOT to use:**
- When a type genuinely needs multiple implementations of the trait
- When the type parameter varies independently (like `Iterator::collect()`)
