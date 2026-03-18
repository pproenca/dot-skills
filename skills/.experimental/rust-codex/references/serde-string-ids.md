---
title: Use Plain String IDs at API Boundaries
impact: HIGH
impactDescription: avoids UUID parsing failures at API boundaries
tags: serde, identifiers, api, string-ids
---

## Use Plain String IDs at API Boundaries

Prefer plain `String` IDs at the API boundary. Parse UUIDs or other structured formats internally if needed. Exposing `Uuid` or custom ID types in wire payloads forces clients to produce exactly the right format, and any format change becomes a breaking API change.

**Incorrect (UUID type exposed at the wire boundary):**

```rust
use uuid::Uuid;

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ThreadReadParams {
    pub thread_id: Uuid,
    pub session_id: Uuid,
}
// Client must send: {"threadId": "550e8400-e29b-41d4-a716-446655440000"}
// Malformed UUIDs cause deserialization failures
```

**Correct (plain String at the boundary, parsed internally):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ThreadReadParams {
    pub thread_id: String,
    pub session_id: String,
}

// Internal parsing when needed:
fn process_thread(params: ThreadReadParams) -> Result<()> {
    let id = Uuid::parse_str(&params.thread_id)
        .context("invalid thread_id format")?;
    // ...
}
```
