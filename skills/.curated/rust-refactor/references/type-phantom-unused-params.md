---
title: Use PhantomData for Unused Generic Parameters
impact: MEDIUM
impactDescription: PhantomData maintains type relationships without runtime overhead
tags: type, phantom-data, generics, marker
---

## Use PhantomData for Unused Generic Parameters

Generic structs that don't directly store a type parameter should use `PhantomData` to maintain the type relationship.

**Incorrect (problematic pattern):**

```rust
// Compile error: parameter `T` is never used
pub struct Container<T> {
    data: Vec<u8>,
}

// Or storing an unnecessary instance
pub struct TypedId<T> {
    id: u64,
    _marker: T,  // Wastes memory, requires Default
}
```

**Correct (recommended pattern):**

```rust
use std::marker::PhantomData;

pub struct Container<T> {
    data: Vec<u8>,
    phantom: PhantomData<T>,  // Zero-sized, maintains type relationship
}

impl<T> Container<T> {
    pub fn new() -> Self {
        Self {
            data: Vec::new(),
            phantom: PhantomData,
        }
    }
}

// Typed IDs without runtime overhead
pub struct TypedId<T> {
    id: u64,
    _marker: PhantomData<T>,
}

impl<T> TypedId<T> {
    pub fn new(id: u64) -> Self {
        Self { id, _marker: PhantomData }
    }
}

// Usage - type safety without overhead
struct User;
struct Order;

let user_id: TypedId<User> = TypedId::new(42);
let order_id: TypedId<Order> = TypedId::new(42);
// user_id and order_id are incompatible types!
```

```rust
// For variance and lifetime relationships
pub struct Ref<'a, T> {
    ptr: *const T,
    _marker: PhantomData<&'a T>,  // Indicates covariant lifetime
}
```

**When NOT to use:**
- When the type parameter is actually used in a field
- Simple wrapper types where PhantomData adds unnecessary complexity
