---
title: Use Arc Notify for Task Completion Signaling
impact: MEDIUM-HIGH
impactDescription: avoids JoinHandle overhead for fire-and-forget coordination
tags: async, notify, task-coordination, signaling
---

## Use Arc Notify for Task Completion Signaling

Use `Arc<Notify>` when a task needs to signal completion or readiness to other tasks without returning a value. This is lighter than `JoinHandle` for fire-and-forget patterns where you only need to know that something finished, not what it returned. The unified exec process module uses this for output draining coordination.

**Incorrect (JoinHandle for simple signal, forces unwrapping the join result):**

```rust
async fn drain_output(child: &mut Child) -> JoinHandle<()> {
    let stdout = child.stdout.take().expect("stdout");
    tokio::spawn(async move {
        let mut buf = vec![0u8; 4096];
        while let Ok(n) = stdout.read(&mut buf).await {
            if n == 0 { break; }
        }
    })
}

// Caller must .await the JoinHandle and handle JoinError
let handle = drain_output(&mut child).await;
handle.await?;
```

**Correct (Arc Notify for lightweight signaling):**

```rust
async fn drain_output(child: &mut Child) -> Arc<Notify> {
    let stdout = child.stdout.take().expect("stdout");
    let done = Arc::new(Notify::new());
    let done_clone = done.clone();
    tokio::spawn(async move {
        let mut buf = vec![0u8; 4096];
        while let Ok(n) = stdout.read(&mut buf).await {
            if n == 0 { break; }
        }
        done_clone.notify_waiters();
    });
    done
}

// Caller waits for the signal without handling JoinError
let done = drain_output(&mut child).await;
done.notified().await;
```
