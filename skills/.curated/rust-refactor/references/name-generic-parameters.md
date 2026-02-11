---
title: Use Descriptive or Single-Letter Generic Parameters
impact: LOW
impactDescription: Appropriate generic naming balances readability with convention
tags: name, generics, type-parameters, conventions
---

## Use Descriptive or Single-Letter Generic Parameters

Generic types can use single letters (T, K, V) for simple cases or descriptive names (FrameType, SampleType) for complex generic relationships.

**Incorrect (problematic pattern):**

```rust
// Meaningless letters for complex relationships
struct Advance<A, B> {
    store: Box<dyn ModelStore<SampleType = A, ModelType = B>>,
    // What are A and B? Hard to understand
}

// Overly verbose for simple cases
struct Wrapper<WrappedInnerType> {
    inner: WrappedInnerType,
}
```

**Correct (recommended pattern):**

```rust
// Single letters for simple, conventional uses
struct Wrapper<T> {
    inner: T,
}

struct HashMap<K, V> {
    // K = Key, V = Value - well understood
}

fn process<T: Debug>(item: T) { ... }

// Descriptive names for complex relationships
struct Advance<FrameType, MType> {
    store: Box<dyn ModelStore<SampleType = FrameType, ModelType = MType>>,
    // Clear what each parameter represents
}

trait Store {
    type SampleType;        // Descriptive associated type
    type ModelType;

    fn get_sample(&self) -> Option<Self::SampleType>;
}

// Mixed approach for common + specific
struct Container<T, Key: Ord> {
    items: BTreeMap<Key, T>,
}
```

**Common conventions:**
| Letter | Meaning | Example |
|--------|---------|---------|
| `T` | Generic type | `Vec<T>` |
| `K` | Key type | `HashMap<K, V>` |
| `V` | Value type | `HashMap<K, V>` |
| `E` | Error type | `Result<T, E>` |
| `F` | Function/closure | `fn map<F>(f: F)` |
| `S` | State | `Parser<S>` |
| `R` | Reader | `BufRead<R>` |
| `W` | Writer | `BufWrite<W>` |
