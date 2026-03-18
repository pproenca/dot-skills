---
title: Avoid Timing-Dependent Assertions
impact: MEDIUM
impactDescription: prevents flaky failures on slow CI machines and under load
tags: det, timing, flaky-tests, ci-reliability
---

## Avoid Timing-Dependent Assertions

Never assert on specific durations, exact timing, or assume operations complete within a fixed window. CI machines run under varying loads, and timing-dependent assertions cause intermittent failures. Use event-based synchronization (wait_for_event) or condition-based polling instead.

**Incorrect (timing assertion fails under CI load):**

```rust
#[tokio::test]
async fn test_response_arrives_quickly() {
    let start = Instant::now();
    codex.submit(Op::UserTurn { content: "hello".into() }).await.unwrap();
    wait_for_event(&codex, |ev| matches!(ev, EventMsg::TaskComplete { .. })).await;
    let elapsed = start.elapsed();
    assert!(elapsed < Duration::from_millis(500));
    // Fails on slow CI: elapsed was 623ms
}
```

**Correct (assert on outcome, not timing):**

```rust
#[tokio::test]
async fn test_response_arrives() {
    codex.submit(Op::UserTurn { content: "hello".into() }).await.unwrap();
    let event = wait_for_event(
        &codex,
        |ev| matches!(ev, EventMsg::TaskComplete { .. }),
    ).await;
    // wait_for_event has a generous internal timeout
    assert!(matches!(event, EventMsg::TaskComplete { .. }));
}
```
