---
title: Use Box::pin for Large Async Stack Frames
impact: MEDIUM-HIGH
impactDescription: prevents stack overflow on Windows where default stack is 1MB
tags: async, box-pin, stack-overflow, futures
---

## Use Box::pin for Large Async Stack Frames

Wrap large or recursive async futures in `Box::pin()` to move their state from the stack to the heap. Async functions compile into state machines whose size grows with the number of `.await` points and local variables. On Windows (1MB default stack), deeply nested async calls overflow without pinning. The codebase uses this extensively in `ThreadManager` and tool runtimes.

**Incorrect (large async state machine lives on the stack):**

```rust
impl ThreadManager {
    pub async fn start_thread_with_tools(
        &self,
        tools: Vec<ToolSpec>,
        source: ThreadSource,
    ) -> Result<()> {
        // Multiple .await points create a large state machine
        let config = self.load_config().await?;
        let session = self.create_session(&config).await?;
        self.state.spawn_thread(session, tools, source).await
    }
}
```

**Correct (heap-allocated future prevents stack overflow):**

```rust
impl ThreadManager {
    pub async fn start_thread_with_tools(
        &self,
        tools: Vec<ToolSpec>,
        source: ThreadSource,
    ) -> Result<()> {
        Box::pin(self.state.spawn_thread(
            self.create_session_config(),
            tools,
            source,
        ))
        .await
    }
}
```
