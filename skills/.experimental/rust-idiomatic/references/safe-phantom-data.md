---
title: Use PhantomData for Type-Level Constraints
impact: HIGH
impactDescription: O(0) runtime overhead, prevents misuse at compile time
tags: safe, phantom-data, type-level, generics, zero-cost
---

## Use PhantomData for Type-Level Constraints

Use `PhantomData<T>` when a struct needs to be generic over a type for compile-time safety but does not actually store a value of that type. This is common for marker types, lifetime tracking, and preventing misuse of handles.

**Incorrect (generic parameter unused, compiler error):**

```rust
struct Handle<Stage> {
    id: u64,
    // Error: parameter `Stage` is never used
}
```

**Correct (PhantomData satisfies the compiler, zero-size):**

```rust
use std::marker::PhantomData;

struct Unvalidated;
struct Validated;

struct Handle<Stage> {
    id: u64,
    _marker: PhantomData<Stage>,
}

impl Handle<Unvalidated> {
    fn validate(self) -> Result<Handle<Validated>, ValidationError> {
        check_handle(self.id)?;
        Ok(Handle { id: self.id, _marker: PhantomData })
    }
}
```
