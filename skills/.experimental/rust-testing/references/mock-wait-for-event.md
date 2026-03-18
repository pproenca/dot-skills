---
title: Prefer wait_for_event Over wait_for_event_with_timeout
impact: HIGH
impactDescription: reduces test boilerplate by using the sensible 1-second default timeout
tags: mock, wait-for-event, async, event-polling
---

## Prefer wait_for_event Over wait_for_event_with_timeout

Use `wait_for_event(codex, predicate)` which provides a sensible 1-second default timeout (escalated to a 10-second minimum internally for async startup). Only use `wait_for_event_with_timeout` when a specific test genuinely needs a custom timeout. This keeps test code focused on the assertion logic rather than timeout configuration.

**Incorrect (explicit timeout on every wait call):**

```rust
#[tokio::test]
async fn test_session_starts() {
    let event = wait_for_event_with_timeout(
        &codex,
        |ev| matches!(ev, EventMsg::SessionConfigured { .. }),
        Duration::from_secs(5),
    ).await;
    assert!(matches!(event, EventMsg::SessionConfigured { .. }));
}
```

**Correct (default timeout via wait_for_event):**

```rust
#[tokio::test]
async fn test_session_starts() {
    let event = wait_for_event(
        &codex,
        |ev| matches!(ev, EventMsg::SessionConfigured { .. }),
    ).await;
    assert!(matches!(event, EventMsg::SessionConfigured { .. }));
}
```
