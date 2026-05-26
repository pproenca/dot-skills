---
title: Store JoinHandles as AbortOnDropHandle so Drop cancels them
impact: HIGH
impactDescription: prevents leaked background tasks when a session or turn is cleared
tags: async, cancellation, structured-concurrency, tokio-util
---

## Store JoinHandles as AbortOnDropHandle so Drop cancels them

A raw `JoinHandle` forces every cleanup path to remember `handle.abort()`; one missed error branch and the task leaks, running on against state that's being torn down. Codex stores tasks as `tokio_util::task::AbortOnDropHandle` inside its state structs, so dropping the owner aborts the task automatically — clearing the turn's task map is enough, with no abort call to forget. When a task is *meant* to outlive its owner, that intent is made explicit with `.detach()` rather than left implicit.

**Incorrect (easy to leak tasks on error paths):**

```rust
pub(crate) struct RunningTask {
    pub(crate) handle: JoinHandle<()>,
}
fn clear_turn(turn: &mut ActiveTurn) {
    for task in turn.drain_tasks() {
        task.handle.abort(); // every error branch must remember this
    }
}
```

**Correct (Drop does the work; detach is the deliberate opt-out):**

```rust
// core/src/state/turn.rs
pub(crate) struct RunningTask {
    pub(crate) cancellation_token: CancellationToken,
    pub(crate) handle: AbortOnDropHandle<()>,
    /* ... */
}

// core/src/tasks/mod.rs — construction site
let handle = tokio::spawn(async move { /* task body */ }.instrument(task_span));
turn.add_task(RunningTask { handle: AbortOnDropHandle::new(handle), /* ... */ });

// core/src/state/turn.rs — when removal should NOT cancel, say so explicitly
let task = self.tasks.swap_remove(sub_id)?;
task.handle.detach(); // intentionally let it finish after removal
```

Clearing the `IndexMap<String, RunningTask>` drops every `AbortOnDropHandle`, which aborts each underlying task — you never grep for "where is the abort". The one place a task should survive removal calls `detach()`, so the exception is visible in the code rather than being an accidental leak. Pair with [[async-child-cancellation-tokens]] for cooperative shutdown before the hard abort.

Reference: `codex-rs/core/src/state/turn.rs:77`, `codex-rs/core/src/tasks/mod.rs:445`.
