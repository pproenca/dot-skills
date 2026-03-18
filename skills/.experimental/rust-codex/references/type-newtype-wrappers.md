---
title: Use Newtype Wrappers for Domain Identifiers
impact: CRITICAL
impactDescription: prevents mixing up plain String IDs at compile time
tags: type, newtype, identifiers, type-safety
---

## Use Newtype Wrappers for Domain Identifiers

Wrap domain identifiers in newtype structs instead of passing raw `String` values. This prevents accidentally swapping two string parameters (e.g., `thread_id` and `user_id`) at a callsite. The compiler catches mismatches at build time instead of producing silent runtime bugs.

**Incorrect (two String params are interchangeable at callsites):**

```rust
fn get_thread(thread_id: String, session_id: String) -> Result<Thread> {
    // Caller can write get_thread(session_id, thread_id) without error
    db.query(&thread_id, &session_id)
}
```

**Correct (compiler rejects swapped arguments):**

```rust
use codex_protocol::ThreadId;

struct SessionId(String);

fn get_thread(thread_id: ThreadId, session_id: SessionId) -> Result<Thread> {
    // get_thread(session_id, thread_id) is a compile error
    db.query(&thread_id.0, &session_id.0)
}
```
