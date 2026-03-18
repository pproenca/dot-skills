---
title: Use CancellationToken for Shutdown Coordination
impact: MEDIUM-HIGH
impactDescription: enables clean hierarchical shutdown across task trees
tags: async, cancellation, shutdown, tokio-util
---

## Use CancellationToken for Shutdown Coordination

Use `tokio_util::sync::CancellationToken` for coordinated shutdown across multiple tasks. Tokens support hierarchical cancellation via `.child_token()`, so cancelling a parent automatically cancels all children. This is used throughout the codebase for process management, MCP connections, and exec runtimes.

**Incorrect (ad-hoc bool flag for shutdown, races with task spawning):**

```rust
struct ProcessManager {
    should_stop: Arc<AtomicBool>,
}

impl ProcessManager {
    async fn run(&self) {
        loop {
            if self.should_stop.load(Ordering::Relaxed) {
                break;
            }
            tokio::time::sleep(Duration::from_millis(100)).await;
            self.do_work().await;
        }
    }
}
```

**Correct (CancellationToken with hierarchical child tokens):**

```rust
use tokio_util::sync::CancellationToken;

struct ProcessManager {
    cancellation_token: CancellationToken,
}

impl ProcessManager {
    async fn run(&self) {
        loop {
            tokio::select! {
                _ = self.cancellation_token.cancelled() => break,
                _ = self.do_work() => {}
            }
        }
    }

    fn spawn_child(&self) -> CancellationToken {
        self.cancellation_token.child_token()
    }
}
```
