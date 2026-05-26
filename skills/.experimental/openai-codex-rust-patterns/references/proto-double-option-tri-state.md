---
title: Use double-nested Options to distinguish absent, null, and set
impact: MEDIUM-HIGH
impactDescription: eliminates invented FieldAction enums for PATCH-like update APIs
tags: proto, serde, api-design, tri-state
---

## Use double-nested Options to distinguish absent, null, and set

In a PATCH-like update API a plain `Option<T>` collapses "leave this field alone" and "explicitly clear this field" into one state. `Option<Option<T>>` recovers the third state — but only if you wire up the deserializer, because serde's default maps a JSON `null` straight to the *outer* `None`, making it indistinguishable from an omitted field. Codex routes these fields through `serde_with::rust::double_option` so `None` = omitted (leave unchanged), `Some(None)` = JSON `null` (clear), and `Some(Some(v))` = set.

**Incorrect (plain Option, or a bare `Option<Option<T>>` without the helper):**

```rust
// Both of these collapse "clear" into "unchanged":
service_tier: Option<String>,           // {"service_tier": null} == field omitted
service_tier: Option<Option<String>>,   // null still deserializes to the OUTER None
```

**Correct (double-option helper wired via deserialize_with):**

```rust
// app-server-protocol/src/protocol/v2/thread.rs
#[serde(
    default,
    deserialize_with = "crate::protocol::serde_helpers::deserialize_double_option",
    serialize_with = "crate::protocol::serde_helpers::serialize_double_option",
    skip_serializing_if = "Option::is_none"
)]
pub service_tier: Option<Option<String>>,

// app-server-protocol/src/protocol/serde_helpers.rs — one shared implementation
pub fn deserialize_double_option<'de, T, D>(d: D) -> Result<Option<Option<T>>, D::Error>
where T: Deserialize<'de>, D: Deserializer<'de> {
    serde_with::rust::double_option::deserialize(d)
}
```

`#[serde(default)]` supplies the omitted → `None` case; `deserialize_double_option` forces a present-but-`null` value to `Some(None)` instead of letting it fold back to `None`. Centralizing the helper in `serde_helpers.rs` means every mutation-shaped field (`ThreadStartParams`, `TurnOptions`, process/realtime params) shares one implementation — no per-field `FieldAction<T> { Unchanged, Clear, Set(T) }` enum with three mappings each.

Reference: `codex-rs/app-server-protocol/src/protocol/v2/thread.rs:100`, `codex-rs/app-server-protocol/src/protocol/serde_helpers.rs:16`.
