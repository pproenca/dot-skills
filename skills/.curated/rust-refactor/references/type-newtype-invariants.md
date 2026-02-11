---
title: Encode Invariants in Newtype Constructors
impact: CRITICAL
impactDescription: enforces validity at type level, eliminates defensive checks
tags: type, newtype, invariants, validation, constructor
---

## Encode Invariants in Newtype Constructors

Use private fields with validated constructors to enforce invariants at the type level. Once constructed, the type is guaranteed valid everywhere.

**Incorrect (repeated validation throughout codebase):**

```rust
fn process_user_id(user_id: u64) {
    if user_id == 0 {
        panic!("Invalid user ID");
    }
    // Business logic
}

fn update_user(user_id: u64) {
    if user_id == 0 {
        panic!("Invalid user ID");  // Duplicated check
    }
    // More business logic
}
```

**Correct (validated once at construction):**

```rust
pub struct UserId(u64);

impl UserId {
    pub fn new(id: u64) -> Option<Self> {
        if id == 0 {
            None
        } else {
            Some(UserId(id))
        }
    }

    pub fn get(&self) -> u64 {
        self.0
    }
}

fn process_user_id(user_id: UserId) {
    // No validation needed - UserId is always valid
}

fn update_user(user_id: UserId) {
    // No validation needed - UserId is always valid
}
```

**Benefits:**
- Validation logic exists in exactly one place
- Invalid states become unrepresentable
- Functions can trust their inputs

Reference: [Type Safety - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/type-safety.html)
