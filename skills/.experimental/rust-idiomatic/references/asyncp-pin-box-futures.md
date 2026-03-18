---
title: Pin Boxed Futures to Reduce Async Stack Size
impact: MEDIUM-HIGH
impactDescription: prevents stack overflows in deeply nested async call chains
tags: asyncp, pin, box, futures, stack-size, memory
---

## Pin Boxed Futures to Reduce Async Stack Size

Use `Box::pin(async { ... })` for large or recursive async operations. Each `.await` point captures the entire future's state on the caller's stack frame. Boxing moves the future to the heap, keeping the parent frame small.

**Incorrect (large future inlined on the stack):**

```rust
async fn orchestrate_turn(
    session: Arc<Session>,
    context: Arc<TurnContext>,
    input: Vec<UserInput>,
) -> Option<String> {
    let result = process_input(&session, &context, &input).await;
    let enriched = enrich_response(&session, &context, result).await;
    finalize_turn(&session, &context, enriched).await
}
```

**Correct (boxed to reduce stack pressure):**

```rust
fn orchestrate_turn(
    session: Arc<Session>,
    context: Arc<TurnContext>,
    input: Vec<UserInput>,
) -> Pin<Box<dyn Future<Output = Option<String>> + Send>> {
    Box::pin(async move {
        let result = process_input(&session, &context, &input).await;
        let enriched = enrich_response(&session, &context, result).await;
        finalize_turn(&session, &context, enriched).await
    })
}
```

**When NOT to use this pattern:**

- Simple async functions with 1-2 await points and small captured state
- Performance-critical hot loops where heap allocation overhead matters
