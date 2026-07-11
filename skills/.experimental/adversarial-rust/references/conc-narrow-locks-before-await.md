---
title: Extract or scope the guard before the await — even the tokio guard
tags: conc, mutex, await, lock-scope
---

## Extract or scope the guard before the await — even the tokio guard

Holding a `MutexGuard` across an `.await` parks the lock for the full duration of the awaited I/O — deadlock with a `std` guard, runtime-wide contention even with an async one. The imported habit "just use the async Mutex, then it's fine" is exactly what codex-rs forbids: its `clippy.toml` lists `tokio::sync::MutexGuard` and both `RwLock` guards as invalid-to-hold-across-await, on top of denying `await_holding_lock`. The mechanical patterns that satisfy it: clone the needed data out in a block and let the guard drop before awaiting (the dominant shape in `core/src/session`), or scope the guard in `{ ... }` and await after. `std::sync::Mutex` remains the right flavor for sync-only sections — codex-rs uses it 2:1 over the tokio mutex, including from `Drop` impls.

**Incorrect (guard alive across the await — tokio mutex does not absolve it):**

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Clone)]
struct SessionConfiguration {
    model: String,
}

struct SessionState {
    configuration: SessionConfiguration,
}

async fn run_turn(state: Arc<Mutex<SessionState>>) {
    let guard = state.lock().await;
    send_prompt(&guard.configuration).await; // lock held for the whole network call
}

async fn send_prompt(configuration: &SessionConfiguration) {
    let _ = &configuration.model;
}
```

**Correct (snapshot out, guard drops, then await — how codex-rs reads session state):**

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Clone)]
struct SessionConfiguration {
    model: String,
}

struct SessionState {
    configuration: SessionConfiguration,
}

async fn run_turn(state: Arc<Mutex<SessionState>>) {
    let configuration = {
        let guard = state.lock().await;
        guard.configuration.clone()
    }; // guard dropped here
    send_prompt(&configuration).await;
}

async fn send_prompt(configuration: &SessionConfiguration) {
    let _ = &configuration.model;
}
```

**When holding across an await IS the design:** two lock-touching steps must be atomic. codex-rs has 36 such non-test sites, every one carrying `#[expect(clippy::await_holding_invalid_type, reason = "active turn checks and turn state updates must remain atomic")]` — the exception is legal only with the atomicity argument written at the site, which is precisely what makes it reviewable.

Reference: [codex-rs clippy.toml](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/clippy.toml#L3), [codex-rs core/src/session/mod.rs snapshot pattern](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/mod.rs#L1097), [codex-rs core/src/session/mod.rs justified atomic hold](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/mod.rs#L2143)
