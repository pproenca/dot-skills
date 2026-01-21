---
title: Group Related Trait Implementations Together
impact: LOW
impactDescription: Grouped impls improve code navigation and review
tags: type, traits, impl, organization
---

## Group Related Trait Implementations Together

Multiple trait implementations for the same type should be grouped together in the source file. Keep inherent methods before trait impls.

**Incorrect (problematic pattern):**

```rust
// Scattered implementations - hard to review
impl From<u32> for Field {
    fn from(v: u32) -> Self { Field::U32(v) }
}

impl Field {
    pub fn as_u64(&self) -> Option<u64> { ... }
}

impl From<u64> for Field {
    fn from(v: u64) -> Self { Field::U64(v) }
}

impl PartialEq for Field { ... }

impl From<String> for Field {
    fn from(v: String) -> Self { Field::Str(v) }
}

impl Display for Field { ... }
```

**Correct (recommended pattern):**

```rust
// 1. Inherent methods first
impl Field {
    pub fn new() -> Self { ... }
    pub fn as_u64(&self) -> Option<u64> { ... }
    pub fn as_str(&self) -> Option<&str> { ... }
}

// 2. From implementations grouped
impl From<u32> for Field {
    fn from(v: u32) -> Self { Field::U32(v) }
}

impl From<u64> for Field {
    fn from(v: u64) -> Self { Field::U64(v) }
}

impl From<i32> for Field {
    fn from(v: i32) -> Self { Field::I32(v) }
}

impl From<String> for Field {
    fn from(v: String) -> Self { Field::Str(v) }
}

// 3. Comparison traits grouped
impl PartialEq for Field { ... }
impl Eq for Field {}
impl PartialOrd for Field { ... }

// 4. Display/Debug grouped
impl Display for Field { ... }
impl Debug for Field { ... }

// 5. Operator overloads grouped
impl Add for Field { ... }
impl Sub for Field { ... }
```

**When NOT to use:**
- When implementations are in separate modules by design
- Generated code where ordering is controlled externally
