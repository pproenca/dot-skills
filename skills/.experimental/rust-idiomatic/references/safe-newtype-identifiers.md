---
title: Use Newtype Pattern for Type-Safe Identifiers
impact: HIGH
impactDescription: eliminates identifier confusion bugs at compile time
tags: safe, newtype, identifiers, type-safety, domain
---

## Use Newtype Pattern for Type-Safe Identifiers

Wrap primitive types in single-field structs to create distinct types for identifiers. Passing a `ThreadId` where a `SessionId` is expected becomes a compile error instead of a silent runtime bug.

**Incorrect (string IDs are interchangeable):**

```rust
fn resolve_thread(
    session_id: String,
    thread_id: String,
) -> Result<Thread, LookupError> {
    // Easy to swap session_id and thread_id by accident
    db.query(&thread_id, &session_id)
}
```

**Correct (newtypes prevent accidental swaps):**

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct SessionId(String);

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct ThreadId(String);

fn resolve_thread(
    session_id: &SessionId,
    thread_id: &ThreadId,
) -> Result<Thread, LookupError> {
    db.query(&thread_id.0, &session_id.0)
}
```
