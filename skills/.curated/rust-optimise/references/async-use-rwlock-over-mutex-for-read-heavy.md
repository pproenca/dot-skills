---
title: Use RwLock Over Mutex for Read-Heavy Workloads
impact: MEDIUM-HIGH
impactDescription: 2-10× throughput for read-heavy workloads
tags: async, rwlock, mutex, lock, concurrency
---

## Use RwLock Over Mutex for Read-Heavy Workloads

`Mutex` allows only one accessor at a time. `RwLock` allows multiple concurrent readers, blocking only for writers.

**Incorrect (serialized reads):**

```rust
use tokio::sync::Mutex;

struct Cache {
    data: Mutex<HashMap<String, User>>,
}

impl Cache {
    async fn get(&self, key: &str) -> Option<User> {
        let data = self.data.lock().await;  // Blocks all other readers
        data.get(key).cloned()
    }
}
```

**Correct (concurrent reads):**

```rust
use tokio::sync::RwLock;

struct Cache {
    data: RwLock<HashMap<String, User>>,
}

impl Cache {
    async fn get(&self, key: &str) -> Option<User> {
        let data = self.data.read().await;  // Multiple readers allowed
        data.get(key).cloned()
    }

    async fn insert(&self, key: String, user: User) {
        let mut data = self.data.write().await;  // Exclusive access
        data.insert(key, user);
    }
}
```

**When to use Mutex instead:**
- Write-heavy workloads
- Very short critical sections
- When RwLock overhead outweighs benefits

Reference: [tokio::sync::RwLock documentation](https://docs.rs/tokio/latest/tokio/sync/struct.RwLock.html)
