---
title: Use Task-Local Storage for Request Context
impact: CRITICAL
impactDescription: prevents context corruption across concurrent requests
tags: async, task-local, context, tokio, tracing
---

## Use Task-Local Storage for Request Context

Thread-local storage does not work correctly with async tasks because tasks can move between threads. Use task-local storage for per-request context like request IDs or spans.

**Incorrect (thread-local corrupted by task migration):**

```rust
thread_local! {
    static REQUEST_ID: RefCell<Option<Uuid>> = RefCell::new(None);
}

async fn handle_request(request: Request) {
    REQUEST_ID.with(|id| *id.borrow_mut() = Some(request.id));
    // Task may migrate to different thread after this await
    process_request().await;
    // REQUEST_ID may now contain different request's ID!
    log_completion();
}
```

**Correct (task-local follows the task):**

```rust
tokio::task_local! {
    static REQUEST_ID: Uuid;
}

async fn handle_request(request: Request) {
    REQUEST_ID.scope(request.id, async {
        process_request().await;
        REQUEST_ID.with(|id| {
            tracing::info!(request_id = %id, "completed");
        });
    }).await;
}
```

**When NOT to use this pattern:**
- Single-threaded runtime where thread-local is sufficient
- Context can be passed explicitly through function parameters

Reference: [tokio::task_local](https://docs.rs/tokio/latest/tokio/macro.task_local.html)
