---
title: Use newtype pattern for type safety
impact: HIGH
impactDescription: Newtypes prevent mixing up values with the same underlying type
tags: mod, newtype, types, safety
---

# Use newtype pattern for type safety

Wrap primitive types in newtypes for domain-specific meaning.

## Why This Matters

- Compiler catches mixing up IDs
- Self-documenting code
- Type-safe function signatures
- Can add domain-specific methods

**Incorrect (avoid this pattern):**

```rust
// Easy to mix up - both are u64!
fn process_user(user_id: u64, org_id: u64) { }

// Oops - swapped arguments
process_user(org_id, user_id);  // Compiles but wrong!

// String IDs are even worse
fn find_user(user_id: &str, session_id: &str) { }
```

**Correct (recommended):**

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)
pub struct UserId(pub u64);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)
pub struct OrgId(pub u64);

#[derive(Debug, Clone, PartialEq, Eq, Hash)
pub struct SessionId(pub String);

// Type-safe signature
fn process_user(user_id: UserId, org_id: OrgId) { }

// Compiler error if swapped!
process_user(org_id, user_id);  // Error: expected UserId, found OrgId
```

## Implementing Newtypes

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)
#[serde(transparent)
pub struct RequestId(pub u64);

impl RequestId {
    pub fn new() -> Self {
        static COUNTER: AtomicU64 = AtomicU64::new(0);
        Self(COUNTER.fetch_add(1, Ordering::Relaxed))
    }
}

impl fmt::Display for RequestId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "req-{}", self.0)
    }
}
```

## Common Newtypes

- `UserId`, `OrgId`, `ProjectId` - entity identifiers
- `RequestId`, `TraceId` - tracing identifiers
- `Port`, `Timeout` - configuration values
- `Bytes`, `Count` - units of measure
