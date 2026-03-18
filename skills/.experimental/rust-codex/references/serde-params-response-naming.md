---
title: Use Params Response Notification Naming Convention
impact: HIGH
impactDescription: enables automatic code generation and consistent API patterns
tags: serde, naming, api, protocol
---

## Use Params Response Notification Naming Convention

Follow the payload naming convention consistently: `*Params` for request payloads from client to server, `*Response` for server replies, and `*Notification` for server-pushed events. RPC methods follow `<resource>/<method>` with singular resource names (e.g., `thread/read`, `app/list`).

**Incorrect (inconsistent naming breaks convention):**

```rust
pub struct ThreadReadRequest {
    pub thread_id: String,
}

pub struct ThreadReadResult {
    pub messages: Vec<Message>,
}

pub struct ThreadUpdateData {
    pub event_type: String,
}
```

**Correct (Params/Response/Notification convention):**

```rust
pub struct ThreadReadParams {
    pub thread_id: String,
}

pub struct ThreadReadResponse {
    pub messages: Vec<Message>,
}

pub struct ThreadUpdateNotification {
    pub event_type: String,
}
```
