---
title: Use RwLock for Read-Heavy Workloads
impact: HIGH
impactDescription: allows concurrent reads, 10-100× throughput for read-heavy access
tags: sync, rwlock, read-heavy, concurrency, performance
---

## Use RwLock for Read-Heavy Workloads

When reads vastly outnumber writes, `RwLock` allows multiple concurrent readers while still ensuring exclusive write access. This dramatically improves throughput for read-heavy workloads.

**Incorrect (Mutex blocks all readers):**

```rust
struct Cache {
    data: Arc<Mutex<HashMap<Key, Value>>>,
}

impl Cache {
    async fn get(&self, key: &Key) -> Option<Value> {
        let guard = self.data.lock().await;  // Blocks other readers!
        guard.get(key).cloned()
    }
}
```

**Correct (RwLock allows concurrent reads):**

```rust
struct Cache {
    data: Arc<RwLock<HashMap<Key, Value>>>,
}

impl Cache {
    async fn get(&self, key: &Key) -> Option<Value> {
        let guard = self.data.read().await;  // Multiple readers allowed
        guard.get(key).cloned()
    }

    async fn insert(&self, key: Key, value: Value) {
        let mut guard = self.data.write().await;  // Exclusive access for writes
        guard.insert(key, value);
    }
}
```

**When to prefer Mutex:**
- Write-heavy workloads (RwLock has higher overhead)
- Critical sections are very short (lock contention is minimal)
- Simpler code is preferred over maximum throughput

Reference: [tokio::sync::RwLock](https://docs.rs/tokio/latest/tokio/sync/struct.RwLock.html)
