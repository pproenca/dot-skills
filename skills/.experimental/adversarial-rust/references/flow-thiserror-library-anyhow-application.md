---
title: Libraries export matchable error enums; anyhow stays at the binary rim
tags: flow, thiserror, anyhow, error-enums
---

## Libraries export matchable error enums; anyhow stays at the binary rim

The exception habit treats all errors as one opaque bag, which in Rust becomes `anyhow::Result` on every signature — callers can only bubble or print, never match. codex-rs types the errors on every load-bearing surface, one `thiserror` enum per layer: `CodexErr` for the agent domain (variants carry structured payloads like `UnexpectedResponseError { status, url, request_id, .. }`, and `is_retryable()` dispatches on variants, not string sniffing), `ApiError` for the model API, `TransportError`/`StreamError` for HTTP/SSE, `ThreadStoreError` for persistence. It even raises clippy's `large-error-threshold` to 256 bytes specifically "to accommodate richer error variants" — paying size for matchability. `anyhow::Result<()>` appears where it belongs: `fn main()` in `cli`, `exec`, `tui`, `app-server`, where the only consumer is a human reading stderr.

```rust
use thiserror::Error;

#[derive(Debug)]
pub struct UnexpectedResponseError {
    pub status: u16,
    pub url: String,
    pub request_id: Option<String>,
}

impl std::fmt::Display for UnexpectedResponseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "unexpected status {} from {}", self.status, self.url)
    }
}

#[derive(Error, Debug)]
pub enum CodexErr {
    #[error("stream disconnected before completion: {0}")]
    Stream(String),
    #[error("no thread with id: {0}")]
    ThreadNotFound(u64),
    #[error("{0}")]
    UnexpectedStatus(UnexpectedResponseError),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

impl CodexErr {
    pub fn is_retryable(&self) -> bool {
        match self {
            CodexErr::Stream(_) => true,
            CodexErr::UnexpectedStatus(e) => e.status >= 500,
            CodexErr::ThreadNotFound(_) | CodexErr::Io(_) => false,
        }
    }
}

// The binary rim: main() erases to anyhow, because stderr is the consumer.
fn main() -> anyhow::Result<()> {
    Ok(())
}
```

**The review smell:** `pub fn ... -> anyhow::Result<T>` in a *library* crate. codex-rs itself has a handful of these leaks (`config` editing, `state` runtime setup) — treat them as acknowledged drift to review against, not as license: the crates whose errors callers must react to (`protocol`, `codex-api`, `http-client`, `thread-store`) hold the typed line without exception.

Reference: [codex-rs protocol/src/error.rs `CodexErr`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/error.rs#L24), [codex-rs cli/src/main.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/cli/src/main.rs#L956), [codex-rs clippy.toml `large-error-threshold`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/clippy.toml#L18)
