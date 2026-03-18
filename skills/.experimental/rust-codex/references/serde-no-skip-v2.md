---
title: Avoid skip_serializing_if for v2 API Fields
impact: HIGH
impactDescription: prevents silent field omission bugs in the v2 API
tags: serde, skip-serializing, v2-api, wire-format
---

## Avoid skip_serializing_if for v2 API Fields

Never use `#[serde(skip_serializing_if = "Option::is_none")]` on v2 API payload fields. Omitting `None` fields silently changes the wire shape and can break TypeScript clients that expect the field to exist (even if `null`). The only allowed exception is parameterless client-to-server requests where `params` is `Option<()>`.

**Incorrect (field disappears from wire when None):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ThreadReadResponse {
    pub thread_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub next_cursor: Option<String>,
}
// When next_cursor is None, field is missing from JSON entirely
```

**Correct (field always present, null when empty):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ThreadReadResponse {
    pub thread_id: String,
    pub next_cursor: Option<String>,
}
// Wire always includes: {"threadId": "...", "nextCursor": null}
```

**When NOT to use this pattern:**

- Client-to-server `*Params` that use `params: Option<()>` with `#[serde(skip_serializing_if = "Option::is_none")]` for parameterless requests.
- Boolean fields using `#[serde(default, skip_serializing_if = "std::ops::Not::not")]` for false-means-omit semantics.
