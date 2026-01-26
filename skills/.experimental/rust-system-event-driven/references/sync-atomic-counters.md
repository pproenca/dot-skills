---
title: Use Atomics for Simple Counters and Flags
impact: HIGH
impactDescription: lock-free operations, 10-50× faster than mutex for counters
tags: sync, atomic, lock-free, counters, performance
---

## Use Atomics for Simple Counters and Flags

For simple counters and boolean flags, atomic types provide lock-free thread-safe operations that are much faster than mutex-protected values.

**Incorrect (mutex for simple counter):**

```rust
struct Stats {
    requests: Arc<Mutex<u64>>,
}

impl Stats {
    fn increment(&self) {
        let mut guard = self.requests.lock().unwrap();
        *guard += 1;  // Lock acquisition overhead for simple increment
    }
}
```

**Correct (atomic counter):**

```rust
use std::sync::atomic::{AtomicU64, Ordering};

struct Stats {
    requests: AtomicU64,
}

impl Stats {
    fn increment(&self) {
        self.requests.fetch_add(1, Ordering::Relaxed);
    }

    fn get(&self) -> u64 {
        self.requests.load(Ordering::Relaxed)
    }
}
```

**Common atomic patterns:**

```rust
// Boolean flag for shutdown
static SHUTDOWN: AtomicBool = AtomicBool::new(false);

fn request_shutdown() {
    SHUTDOWN.store(true, Ordering::Release);
}

fn is_shutdown() -> bool {
    SHUTDOWN.load(Ordering::Acquire)
}

// Compare-and-swap for state machines
fn try_transition(state: &AtomicU8, from: u8, to: u8) -> bool {
    state.compare_exchange(from, to, Ordering::AcqRel, Ordering::Acquire).is_ok()
}
```

Reference: [std::sync::atomic](https://doc.rust-lang.org/std/sync/atomic/)
