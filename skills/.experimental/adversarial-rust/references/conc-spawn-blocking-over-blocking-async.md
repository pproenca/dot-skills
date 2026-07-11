---
title: Blocking work moves to spawn_blocking; an async fn never blocks its worker
tags: conc, spawn-blocking, async, blocking-io
---

## Blocking work moves to spawn_blocking; an async fn never blocks its worker

Thread-per-request habits call blocking APIs — synchronous file I/O, file locks, compression, a blocking HTTP `recv()` loop — directly inside `async fn`, which stalls the runtime worker and every task multiplexed onto it. codex-rs wraps every such operation in `tokio::task::spawn_blocking` at ~50 production sites: git operations via gix, advisory-file-lock appends to message history (the doc comment states the policy: "performed inside `spawn_blocking` so the caller's async runtime is not blocked"), zstd rollout materialization, the synchronous OAuth callback server, and atomic config-file writes. Its `execpolicy` crate even documents the convention for callers: wrap the sync API in `spawn_blocking` from async contexts.

**Incorrect (a sync durable write on the async worker thread):**

```rust
use std::io::Write;

async fn append_history(path: std::path::PathBuf, line: String) -> std::io::Result<()> {
    let mut file = std::fs::OpenOptions::new().append(true).create(true).open(&path)?;
    file.write_all(line.as_bytes())?;
    file.sync_all()?; // fsync stalls this worker — and every task on it
    Ok(())
}
```

**Correct (the blocking section becomes a closure on the blocking pool — how codex-rs appends message history):**

```rust
use std::io::Write;

async fn append_history(path: std::path::PathBuf, line: String) -> std::io::Result<()> {
    tokio::task::spawn_blocking(move || -> std::io::Result<()> {
        let mut file = std::fs::OpenOptions::new().append(true).create(true).open(&path)?;
        file.write_all(line.as_bytes())?;
        file.sync_all()?; // blocks a blocking-pool thread; the runtime keeps running
        Ok(())
    })
    .await
    .map_err(std::io::Error::other)?
}
```

Ordinary one-shot file reads/writes can use `tokio::fs` directly (codex-rs does, 16 sites in `core`); `spawn_blocking` earns its ceremony when the operation *holds* — an advisory file lock with retries (the real message-history implementation), an fsync, a compression stream, a server loop — or when wrapping a whole synchronous helper. The pairing rule: `std::fs` lives inside `spawn_blocking` closures and sync helpers; async fns call `tokio::fs` or the wrapper.

Reference: [codex-rs message-history/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/message-history/src/lib.rs#L154), [codex-rs git-utils/src/baseline.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/git-utils/src/baseline.rs#L69), [codex-rs rollout/src/compression.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/rollout/src/compression.rs#L67)
