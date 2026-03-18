---
title: Use wait_for_event with Predicate Closures
impact: MEDIUM-HIGH
impactDescription: 100% resilience to event reordering vs 0% with positional indexing
tags: event, wait-for-event, predicates, async-testing
---

## Use wait_for_event with Predicate Closures

Use `wait_for_event(codex, |ev| predicate)` to wait for a specific event by matching its content. This approach is resilient to changes in event ordering. Avoid indexing into an event list by position, which breaks when new events are added between existing ones.

**Incorrect (positional event indexing breaks when events are reordered):**

```rust
#[tokio::test]
async fn test_session_configured() {
    let events = collect_events(&codex, 5).await;
    // Assumes SessionConfigured is always the 3rd event
    assert!(matches!(events[2], EventMsg::SessionConfigured { .. }));
    // Adding a new event type before SessionConfigured breaks this
}
```

**Correct (predicate-based matching is ordering-resilient):**

```rust
#[tokio::test]
async fn test_session_configured() {
    let event = wait_for_event(
        &codex,
        |ev| matches!(ev, EventMsg::SessionConfigured { .. }),
    ).await;
    // Finds SessionConfigured regardless of position in the stream
    assert!(matches!(event, EventMsg::SessionConfigured { .. }));
}
```
