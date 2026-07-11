---
title: Avoid holding a std MutexGuard across an .await
tags: conc, mutex, await, deadlock
---

## Avoid holding a std MutexGuard across an .await

Locking a `std::sync::Mutex` and then `.await`ing while the guard is live is the object-monitor habit ("synchronize the whole method") on a runtime where it turns toxic: the task can be suspended mid-critical-section with the lock held, every other task needing that lock then blocks its worker thread, and if one of them is scheduled on the same worker the runtime deadlocks. The refactor is almost never "switch to `tokio::sync::Mutex`" — it is narrowing the critical section so the guard drops before any `.await`, or moving the state into a dedicated task reached by channels when the critical section genuinely spans awaits.

**Incorrect (guard alive across the await):**

```rust
async fn record_hit(stats: Arc<Mutex<HashMap<Route, u64>>>, route: Route, db: Db) {
    let mut map = stats.lock().unwrap();
    *map.entry(route.clone()).or_insert(0) += 1;
    db.persist(&route).await; // suspended while holding the lock
}
```

**Correct (synchronous critical section, then await):**

```rust
async fn record_hit(stats: Arc<Mutex<HashMap<Route, u64>>>, route: Route, db: Db) {
    {
        let mut map = stats.lock().unwrap();
        *map.entry(route.clone()).or_insert(0) += 1;
    } // guard dropped before suspension
    db.persist(&route).await;
}
```

Enforce it mechanically with clippy's `await_holding_lock`. `tokio::sync::Mutex` is the fallback when the lock *must* straddle an await (it yields instead of blocking) — but its lock costs more, and the tokio tutorial itself recommends the std mutex with narrowed scope as the default.

Reference: [Tokio tutorial — Shared state](https://tokio.rs/tokio/tutorial/shared-state)
