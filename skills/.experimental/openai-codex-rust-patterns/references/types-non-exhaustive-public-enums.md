---
title: Mark public wire-level enums non_exhaustive from the start
impact: HIGH
impactDescription: prevents breaking external match statements when a variant is added
tags: types, enums, api-design, versioning
---

## Mark public wire-level enums non_exhaustive from the start

Adding a variant to a public enum is normally a breaking change — downstream crates write exhaustive matches. `#[non_exhaustive]` tells the compiler to require a `_` arm in external crates, so new variants become additive. Codex puts this on `protocol::Op`, `user_input::UserInput`, and every top-level wire enum in the protocol crate. Because the protocol is used by a CLI, a TUI, multiple external clients, and a TypeScript SDK, committing to exhaustive matches would force a major version bump for every new feature.

**Incorrect (missing attribute — every new variant is a breaking change):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Op {
    Interrupt,
    RealtimeStart(RealtimeParams),
    /* ... */
}
// Downstream `match op { Op::Interrupt => ..., Op::RealtimeStart(_) => ... }`
// won't compile when a new variant is added.
```

**Correct (non_exhaustive plus internally-tagged serde):**

```rust
// protocol/src/protocol.rs
#[derive(Debug, Clone, Deserialize, Serialize, PartialEq, JsonSchema)]
#[serde(tag = "type", rename_all = "snake_case")]
#[allow(clippy::large_enum_variant)]
#[non_exhaustive]
pub enum Op {
    Interrupt,
    CleanBackgroundTerminals,
    RealtimeConversationStart(ConversationStartParams),
    /* 30+ more variants, each additive */
}

// protocol/src/user_input.rs
#[non_exhaustive]
#[derive(Debug, Clone, Deserialize, Serialize, PartialEq, TS, JsonSchema)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum UserInput {
    Text { /* ... */ },
    Image { /* ... */ },
    /* ... */
}
```

The attribute sits above the derives, separate from serde and strum attributes. It is paired with `#[serde(tag = "type")]` so the wire encoding is also version-tolerant — unknown tags fail loudly rather than silently dropping data. Apply it from day one; retrofitting later is as breaking as adding a variant without it.

Reference: `codex-rs/protocol/src/protocol.rs:359`, `codex-rs/protocol/src/user_input.rs:10`.
