---
title: Pair rename and alias to migrate wire names without breaking clients
impact: HIGH
impactDescription: prevents flag-day migrations by keeping old wire names as read-only aliases
tags: proto, serde, versioning, backcompat
---

## Pair rename and alias to migrate wire names without breaking clients

Renaming a variant or field on the wire normally means a flag day — ship the new name and every old client breaks. Codex renames wire strings in place but keeps the old string alive as a read-only alias. `#[serde(rename)]` controls what goes *out*; `#[serde(alias)]` controls what can come *in*. New code writes `task_started`; an old client that still sends `turn_started` parses fine. Combined with `#[non_exhaustive]` on the enum, external crates also cannot write exhaustive matches that would block the migration.

**Incorrect (rename only — every old client breaks):**

```rust
#[serde(rename = "task_started")]
TurnStarted(TurnStartedEvent),
// v1 client sending "turn_started" -> serde error, ignored or crashes.
```

**Correct (rename + alias, documented with a v1/v2 note):**

```rust
// protocol/src/protocol.rs
/// Agent has started a turn.
/// v1 wire format uses `task_started`; accept `turn_started` for v2 interop.
#[serde(rename = "task_started", alias = "turn_started")]
TurnStarted(TurnStartedEvent),

/// Agent has completed all actions.
/// v1 wire format uses `task_complete`; accept `turn_complete` for v2 interop.
#[serde(rename = "task_complete", alias = "turn_complete")]
TurnComplete(TurnCompleteEvent),
```

The Rust identifier (`TurnStarted`) is decoupled from both wire names — renaming internally is free. A doc comment records which name is v1 and which is v2, so future grep-and-refactor passes can find the migration sites. Other files use `#[serde(default, alias = "agent_type")]` when field names (not variants) migrate the same way.

Reference: `codex-rs/protocol/src/protocol.rs:1395`.
