---
title: Bound submissions but leave events unbounded
impact: HIGH
impactDescription: avoids session loop stalls on slow consumers while rate-limiting misbehaving producers
tags: async, channels, backpressure, async-channel
---

## Bound submissions but leave events unbounded

Defaulting every channel to `mpsc::channel(1024)` looks safe, but it creates two opposite bugs: an internal session loop stalls when a UI pauses (because its event channel is full), or an input queue OOMs when a client floods. Codex deliberately splits the two halves of its submission-event pair — user-facing submissions are *bounded* (clients backpressure when they submit too fast, which rate-limits them — a feature), and outbound events are *unbounded* (the event producer is the session loop itself, which must never block on a slow UI consumer or the whole agent stalls).

**Incorrect (uniform bounded channels for both directions):**

```rust
let (submission_tx, submission_rx) = mpsc::channel(1024);
let (event_tx, event_rx) = mpsc::channel(1024);
// Session loop blocks when event_tx fills, even during critical lock sections.
```

**Correct (split: bounded submissions, unbounded events):**

```rust
// core/src/codex.rs
let (tx_sub, rx_sub) = async_channel::bounded(SUBMISSION_CHANNEL_CAPACITY);
let (tx_event, rx_event) = async_channel::unbounded();
```

The decision rule is "who is the producer, and can they afford to wait?". External caller? Bounded, backpressure is a feature. Internal task holding a critical lock? Unbounded, blocking corrupts the session. For latency-sensitive data (audio frames) codex goes further with `try_send` plus drop-on-full: `TrySendError::Full` logs a warning and drops the frame rather than blocking.

Reference: `codex-rs/core/src/codex.rs:495`, `codex-rs/core/src/realtime_conversation.rs:393`.
