---
title: Use parking_lot for High-Contention Locks
impact: HIGH
impactDescription: 2-3× better performance under contention
tags: sync, parking-lot, mutex, contention, performance
---

## Use parking_lot for High-Contention Locks

When locks experience high contention (many threads competing), `parking_lot` provides better performance than std's Mutex through more efficient waiting and smaller lock size.

**Incorrect (std Mutex under high contention):**

```rust
use std::sync::Mutex;

struct Counter {
    value: Mutex<u64>,  // 40 bytes on Linux, potential cache line issues
}

impl Counter {
    fn increment(&self) {
        *self.value.lock().unwrap() += 1;
    }
}
```

**Correct (parking_lot for contended locks):**

```rust
use parking_lot::Mutex;

struct Counter {
    value: Mutex<u64>,  // 1 byte overhead, fits in cache line
}

impl Counter {
    fn increment(&self) {
        *self.value.lock() += 1;  // No unwrap needed, never poisoned
    }
}
```

**Benefits of parking_lot:**
- Smaller size (1 byte for Mutex, 1 word for RwLock)
- No lock poisoning (guards don't need unwrap)
- Faster under contention (fair scheduling, spinning)
- RwLock allows upgrades and downgrades

**When to use std Mutex:**
- Low contention scenarios
- Avoiding additional dependencies
- Need lock poisoning for panic safety

Reference: [parking_lot crate](https://docs.rs/parking_lot/latest/parking_lot/)
