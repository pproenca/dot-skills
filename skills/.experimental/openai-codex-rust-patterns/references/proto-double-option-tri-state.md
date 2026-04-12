---
title: Use double-nested Options to distinguish absent, null, and set
impact: MEDIUM-HIGH
impactDescription: eliminates invented FieldAction enums for PATCH-like update APIs
tags: proto, serde, api-design, tri-state
---

## Use double-nested Options to distinguish absent, null, and set

In PATCH-like update APIs, a plain `Option<T>` collapses "leave this field alone" and "explicitly clear this field" into one state, which destroys the semantics of partial updates. Codex reaches for `Option<Option<T>>` with `serde_with::rust::double_option`: the outer layer means "field omitted from JSON" (leave unchanged), `Some(None)` means the field was sent as JSON `null` (clear it), and `Some(Some(value))` means "set to value".

**Incorrect (plain Option collapses "unchanged" and "clear"):**

```rust
#[derive(Deserialize)]
pub struct OverrideTurnContext {
    service_tier: Option<ServiceTier>,
}
// Sending {"service_tier": null} looks the same as omitting the field.
// Caller must invent a sentinel to mean "clear".
```

**Correct (double Option via serde_with):**

```rust
// protocol/src/protocol.rs
/// Optional service tier override for this turn.
///
/// Use `Some(Some(value))` to set a specific tier for this turn,
/// `Some(None)` to explicitly clear the tier for this turn, or `None`
/// to keep the existing session preference.
#[serde(default, skip_serializing_if = "Option::is_none")]
service_tier: Option<Option<ServiceTier>>,

// app-server-protocol/src/protocol/serde_helpers.rs — centralized helper
pub fn deserialize_double_option<'de, T, D>(
    deserializer: D,
) -> Result<Option<Option<T>>, D::Error>
where
    T: Deserialize<'de>,
    D: Deserializer<'de>,
{
    Deserialize::deserialize(deserializer).map(Some)
}
```

This only appears on the mutation-shaped APIs (`UserTurn`, `OverrideTurnContext`, `ThreadStartParams`). The helper module in `app-server-protocol/src/protocol/serde_helpers.rs` centralizes the `deserialize_double_option` / `serialize_double_option` pair so every call site points at the same implementation — no inventing a `FieldAction<T> { Unchanged, Clear, Set(T) }` enum that requires three mappings per update.

Reference: `codex-rs/protocol/src/protocol.rs:438`, `codex-rs/app-server-protocol/src/protocol/serde_helpers.rs`.
