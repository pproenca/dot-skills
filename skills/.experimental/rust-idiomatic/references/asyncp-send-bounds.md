---
title: Ensure Futures Are Send for Multi-Threaded Runtimes
impact: MEDIUM-HIGH
impactDescription: required for tokio::spawn, prevents runtime panics
tags: asyncp, send, bounds, tokio, spawn, multi-threaded
---

## Ensure Futures Are Send for Multi-Threaded Runtimes

`tokio::spawn` requires the future to be `Send` because the runtime can move it between threads. Holding a non-Send type (e.g., `Rc`, `MutexGuard` from `std`) across an `.await` point makes the future `!Send`, causing a compile error.

**Incorrect (MutexGuard held across await, future is !Send):**

```rust
async fn update_metrics(state: &std::sync::Mutex<MetricsState>) {
    let mut guard = state.lock().unwrap();
    guard.pending_count += 1;
    fetch_latest_metrics().await;
    guard.last_updated = Instant::now();
}
```

**Correct (drop guard before await):**

```rust
async fn update_metrics(state: &std::sync::Mutex<MetricsState>) {
    {
        let mut guard = state.lock().unwrap();
        guard.pending_count += 1;
    }
    fetch_latest_metrics().await;
    {
        let mut guard = state.lock().unwrap();
        guard.last_updated = Instant::now();
    }
}
```

**Alternative (use tokio::sync::Mutex for async-aware locking):**

```rust
async fn update_metrics(state: &tokio::sync::Mutex<MetricsState>) {
    let mut guard = state.lock().await;
    guard.pending_count += 1;
    fetch_latest_metrics().await;
    guard.last_updated = Instant::now();
}
```
