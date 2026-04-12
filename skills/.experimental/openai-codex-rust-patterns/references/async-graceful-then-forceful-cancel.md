---
title: Cancel cooperatively first, then abort after a grace deadline
impact: HIGH
impactDescription: prevents unbounded shutdown latency while still letting well-behaved tasks clean up
tags: async, cancellation, shutdown, tokio
---

## Cancel cooperatively first, then abort after a grace deadline

`CancellationToken::cancel()` is a request, not a kill — the task must reach an `.await` point that observes it. Plain `handle.abort()` skips cleanup entirely. Codex races the task's self-reported "done" `Notify` against a grace timeout in `select!`: signal cancellation, wait for up to `GRACEFULL_INTERRUPTION_TIMEOUT_MS`, then fall back to `handle.abort()`. Well-behaved tasks get time to flush rollouts and emit finalization events; stuck tasks are bounded.

**Incorrect (immediate abort skips cleanup):**

```rust
async fn shutdown_turn(turn: ActiveTurn) {
    for task in turn.drain_tasks() {
        task.handle.abort(); // rollouts, events, locks: all lost
    }
}
```

**Correct (cancel, wait, then abort as fallback):**

```rust
// core/src/tasks/mod.rs
async fn handle_task_abort(
    self: &Arc<Self>,
    task: RunningTask,
    reason: TurnAbortReason,
) {
    if task.cancellation_token.is_cancelled() {
        return;
    }
    task.cancellation_token.cancel();
    // Cancel sub-trackers owned by the task ...
    select! {
        _ = task.done.notified() => {}
        _ = tokio::time::sleep(
            Duration::from_millis(GRACEFULL_INTERRUPTION_TIMEOUT_MS),
        ) => {
            warn!(
                "task {sub_id} didn't complete gracefully after {}ms",
                GRACEFULL_INTERRUPTION_TIMEOUT_MS,
            );
        }
    }
    task.handle.abort(); // hard kill, no-op if task already exited
}
```

`task.done.notified()` is the task's way of volunteering that it reached its cleanup tail; `handle.abort()` is the hard kill. Both always run — `abort()` is a no-op if the task already returned.

Reference: `codex-rs/core/src/tasks/mod.rs:568`.
