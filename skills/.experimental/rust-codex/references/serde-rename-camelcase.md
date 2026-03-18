---
title: Use rename_all camelCase on Wire Types
impact: HIGH
impactDescription: prevents 100% of snake_case wire format mismatches
tags: serde, camelCase, wire-format, serialization
---

## Use rename_all camelCase on Wire Types

All API payload structs must use `#[serde(rename_all = "camelCase")]` to ensure field names are camelCase on the wire. The TypeScript client expects camelCase, and the Rust convention of snake_case must be translated at the serialization boundary.

**Incorrect (snake_case leaks to the wire protocol):**

```rust
#[derive(Serialize, Deserialize)]
pub struct ThreadReadResponse {
    pub thread_id: String,
    pub created_at: i64,
    pub message_count: u32,
}
// Wire: {"thread_id": "...", "created_at": 123, "message_count": 5}
```

**Correct (camelCase on the wire with ts annotation aligned):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[ts(rename_all = "camelCase")]
#[ts(export_to = "v2/")]
pub struct ThreadReadResponse {
    pub thread_id: String,
    pub created_at: i64,
    pub message_count: u32,
}
// Wire: {"threadId": "...", "createdAt": 123, "messageCount": 5}
```

**When NOT to use this pattern:**

- Config RPC payloads use snake_case to mirror config.toml keys.
