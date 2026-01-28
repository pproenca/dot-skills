---
title: Use Manager suffix for lifecycle management
impact: MEDIUM
impactDescription: Clear identification of types that manage resource lifecycles
tags: name, lifecycle, types
---

# Use Manager suffix for lifecycle management

Types that manage resource lifecycles should use the `Manager` suffix.

## Why This Matters

- Identifies ownership/lifecycle responsibility
- Clear resource management pattern
- Distinguishes from the resources themselves
- Common pattern in async Rust

**Incorrect (avoid this pattern):**

```rust
// Unclear lifecycle responsibility
pub struct Threads { }      // Collection or manager?
pub struct Connections { }  // Pool or active set?
pub struct Tasks { }        // List or scheduler?
```

**Correct (recommended):**

```rust
/// Manages background thread lifecycles.
pub struct ThreadManager {
    threads: HashMap<ThreadId, JoinHandle<()>>,
    shutdown_tx: broadcast::Sender<()>,
}

impl ThreadManager {
    pub fn spawn(&mut self, name: &str, task: impl FnOnce() + Send + 'static) -> ThreadId;
    pub fn stop(&mut self, id: ThreadId) -> Result<(), ThreadError>;
    pub async fn shutdown_all(&mut self);
}

/// Manages database connection pool.
pub struct ConnectionManager {
    pool: Pool<Postgres>,
    max_connections: usize,
}

/// Manages background task execution.
pub struct TaskManager {
    tasks: HashMap<TaskId, JoinHandle<()>>,
    runtime: Handle,
}

/// Manages subscription lifecycles.
pub struct SubscriptionManager {
    subscriptions: HashMap<SubscriptionId, Subscription>,
}
```

## Manager Pattern

```rust
impl ThreadManager {
    pub fn new() -> Self { }

    /// Spawns a new managed thread.
    pub fn spawn<F>(&mut self, f: F) -> ThreadId
    where
        F: FnOnce() + Send + 'static,
    {
        let id = ThreadId::new();
        let handle = std::thread::spawn(f);
        self.threads.insert(id, handle);
        id
    }

    /// Joins and removes a thread.
    pub fn join(&mut self, id: ThreadId) -> Result<(), ThreadError> {
        let handle = self.threads.remove(&id)
            .ok_or(ThreadError::NotFound)?;
        handle.join().map_err(|_| ThreadError::Panicked)
    }
}
```
