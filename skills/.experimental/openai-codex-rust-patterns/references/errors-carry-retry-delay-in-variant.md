---
title: Carry the server-requested retry delay inside the error variant
impact: HIGH
impactDescription: eliminates out-of-band retry-after plumbing through the error flow
tags: errors, retry, backoff, thiserror
---

## Carry the server-requested retry delay inside the error variant

When the server sends `Retry-After` headers or encodes per-error delays, the naive approach is to thread `retry_after: Option<Duration>` alongside the error as a second return value, or stash it on the session struct. Codex puts the delay *inside* the error variant itself, so the retry loop pattern-matches to pick between "server said wait 2s" and "default exponential backoff". No extra argument plumbing, no side-channel state.

**Incorrect (side-channel delay, prone to drift):**

```rust
fn send_turn(&self) -> Result<Turn, (CodexErr, Option<Duration>)> { /* ... */ }

match self.send_turn() {
    Err((err, Some(d))) => tokio::time::sleep(d).await,
    Err((err, None)) => tokio::time::sleep(default_backoff()).await,
    Ok(turn) => return Ok(turn),
}
```

**Correct (delay lives inside the variant):**

```rust
// protocol/src/error.rs
#[derive(Debug, thiserror::Error)]
pub enum CodexErr {
    /// Optionally includes the requested delay before retrying the turn.
    #[error("stream disconnected before completion: {0}")]
    Stream(String, Option<Duration>),
    /* other variants */
}

// core/src/codex.rs — retry loop reads the hint directly
let delay = match &err {
    CodexErr::Stream(_, requested_delay) => {
        requested_delay.unwrap_or_else(|| backoff(retries))
    }
    _ => backoff(retries),
};
tokio::time::sleep(delay).await;
```

The two-tuple variant `Stream(String, Option<Duration>)` is unusual — most thiserror users would define a struct variant. The positional form makes the "this carries a delay hint" fact visible at every construction site.

Reference: `codex-rs/protocol/src/error.rs:78`, `codex-rs/core/src/codex.rs:6862`.
