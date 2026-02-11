---
title: Implement Operator Traits for Domain Types
impact: MEDIUM
impactDescription: Operator overloading enables natural syntax for domain-specific arithmetic
tags: type, operators, traits, add, sub
---

## Implement Operator Traits for Domain Types

Implement standard `ops` traits for domain types that have natural mathematical operations. This enables intuitive syntax.

**Incorrect (problematic pattern):**

```rust
// Manual method calls - verbose
impl CgroupIoModel {
    pub fn add(&self, other: &Self) -> Self {
        Self {
            rbytes_per_sec: add_options(self.rbytes_per_sec, other.rbytes_per_sec),
            wbytes_per_sec: add_options(self.wbytes_per_sec, other.wbytes_per_sec),
        }
    }
}

// Usage - awkward
let total = model1.add(&model2).add(&model3);
```

**Correct (recommended pattern):**

```rust
use std::ops::Add;

impl std::ops::Add<&CgroupIoModel> for CgroupIoModel {
    type Output = Self;

    fn add(self, other: &Self) -> Self {
        Self {
            rbytes_per_sec: opt_add(self.rbytes_per_sec, other.rbytes_per_sec),
            wbytes_per_sec: opt_add(self.wbytes_per_sec, other.wbytes_per_sec),
            riops: opt_add(self.riops, other.riops),
            wiops: opt_add(self.wiops, other.wiops),
        }
    }
}

// Helper for Option arithmetic
fn opt_add(a: Option<f64>, b: Option<f64>) -> Option<f64> {
    match (a, b) {
        (Some(a), Some(b)) => Some(a + b),
        (Some(a), None) => Some(a),
        (None, Some(b)) => Some(b),
        (None, None) => None,
    }
}

// Usage - natural
let total = model1 + &model2 + &model3;

// Also implement AddAssign for +=
impl std::ops::AddAssign<&CgroupIoModel> for CgroupIoModel {
    fn add_assign(&mut self, other: &Self) {
        *self = self.clone() + other;
    }
}

// Usage
total += &model4;
```

**When NOT to use:**
- When the operation semantics aren't intuitive for the type
- When it would conflict with the type's primary purpose
