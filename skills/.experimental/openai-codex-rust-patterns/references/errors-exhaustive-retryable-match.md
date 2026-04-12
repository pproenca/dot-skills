---
title: Classify retryable errors via an exhaustive match
impact: CRITICAL
impactDescription: prevents silent retry drift when a new error variant is added
tags: errors, retry, thiserror, exhaustive-match
---

## Classify retryable errors via an exhaustive match

A retry loop that uses `matches!(err, ErrorA | ErrorB)` or string-matching on error messages silently breaks every time a new variant is added — retryability is decided by whoever last touched the match site, not by the author of the new error. Codex defines `is_retryable(&self) -> bool` as a single `match self` listing every variant in both arms. The enum is deliberately NOT `#[non_exhaustive]`, so adding a variant forces a compile error in this function until the author classifies it.

**Incorrect (positive list with wildcard — new variants silently fall through):**

```rust
impl CodexErr {
    pub fn is_retryable(&self) -> bool {
        matches!(
            self,
            CodexErr::Stream(..) | CodexErr::Timeout | CodexErr::Io(_)
        )
        // A new CodexErr::BrokenPipe returns false by default.
    }
}
```

**Correct (exhaustive match, no wildcard arm):**

```rust
// protocol/src/error.rs
pub fn is_retryable(&self) -> bool {
    match self {
        CodexErr::TurnAborted
        | CodexErr::Interrupted
        | CodexErr::EnvVar(_)
        | CodexErr::Fatal(_) => false,
        CodexErr::Stream(..)
        | CodexErr::Timeout
        | CodexErr::UnexpectedStatus(_)
        | CodexErr::ResponseStreamFailed(_)
        | CodexErr::ConnectionFailed(_)
        | CodexErr::Io(_)
        | CodexErr::Json(_)
        | CodexErr::TokioJoin(_) => true,
        #[cfg(target_os = "linux")]
        CodexErr::LandlockRuleset(_)
        | CodexErr::LandlockPathFd(_) => false,
    }
}
```

Both arms list every variant. The companion retry loop becomes a one-liner: `if !err.is_retryable() { return Err(err); }`. Impact is compile-time — a PR that adds `BrokenPipe` cannot merge until the author picks which bucket it belongs to.

Reference: `codex-rs/protocol/src/error.rs:168`, `codex-rs/core/src/codex.rs:6838`.
