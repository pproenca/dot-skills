---
title: Own every spawned task's handle; cancel is graceful-then-abort
tags: conc, spawn, cancellation, task-lifecycle
---

## Own every spawned task's handle; cancel is graceful-then-abort

`tokio::spawn(async move { ... });` with the handle discarded is the detached-promise habit: the task outlives the operation that spawned it, keeps mutating shared state after its parent gave up, and can neither be cancelled nor awaited on shutdown. codex-rs never leaks a turn: the spawned task's `JoinHandle` is stored in the turn state wrapped in `AbortOnDropHandle` (dropping the owner cancels the task), cancellation flows in as a child `CancellationToken`, completion signals out through a `Notify` — and interruption is staged: cancel the token, `select!` the task's done-signal against a timeout, and only then hard-`abort()`. Dynamic pools get the same treatment through `JoinSet`, which reaps with `join_next()` and supports `abort_all()`.

**Incorrect (fire-and-forget; nobody can stop or await this):**

```rust
fn start_turn() {
    tokio::spawn(async move {
        run_model_turn().await;
    }); // handle dropped: the turn now outlives every owner
}

async fn run_model_turn() {}
```

**Correct (handle owned, cancel cooperative first, abort as backstop — how codex-rs runs a turn):**

```rust
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Notify;
use tokio_util::sync::CancellationToken;
use tokio_util::task::AbortOnDropHandle;

struct RunningTask {
    done: Arc<Notify>,
    cancellation_token: CancellationToken,
    handle: AbortOnDropHandle<()>,
}

fn start_turn() -> RunningTask {
    let cancellation_token = CancellationToken::new();
    let done = Arc::new(Notify::new());
    let child_token = cancellation_token.child_token();
    let done_clone = Arc::clone(&done);
    let handle = tokio::spawn(async move {
        tokio::select! {
            _ = child_token.cancelled() => {}
            _ = run_model_turn() => {}
        }
        done_clone.notify_waiters();
    });
    RunningTask {
        done,
        cancellation_token,
        // Dropping RunningTask aborts the task: no orphans possible.
        handle: AbortOnDropHandle::new(handle),
    }
}

async fn interrupt(task: RunningTask) {
    task.cancellation_token.cancel();
    tokio::select! {
        _ = task.done.notified() => {}
        _ = tokio::time::sleep(Duration::from_millis(400)) => {}
    }
    task.handle.abort(); // backstop after the grace window
}

async fn run_model_turn() {}
```

The order matters: cooperative cancel lets the task flush events and release resources; the timeout bounds how long a stuck task can delay the user; the abort guarantees termination. Skipping straight to `abort()` loses in-flight work; skipping the abort trusts every task to be well-behaved.

Reference: [codex-rs core/src/tasks/mod.rs spawn + AbortOnDropHandle](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tasks/mod.rs#L344), [codex-rs core/src/tasks/mod.rs graceful interrupt](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tasks/mod.rs#L836), [codex-rs app-server/src/connection_cleanup.rs `JoinSet`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/connection_cleanup.rs#L8)
