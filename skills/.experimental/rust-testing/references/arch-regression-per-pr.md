---
title: Write Regression Tests for Every Bug Fix
impact: CRITICAL
impactDescription: 3-6 regression tests per PR prevents bug reintroduction
tags: arch, regression, testing-strategy, coverage
---

## Write Regression Tests for Every Bug Fix

Every bug fix PR must include 3-6 regression tests that reproduce the original failure and verify the fix. This codebase standard ensures bugs never reappear and each fix permanently hardens the test suite.

**Incorrect (fix without regression coverage):**

```rust
// PR: "Fix off-by-one in truncation logic"
// Only changes production code, no tests added
pub fn truncate_messages(messages: &[Message], limit: usize) -> Vec<Message> {
    messages[..limit.min(messages.len())].to_vec() // fixed from messages[..limit]
}
```

**Correct (fix with regression tests covering edge cases):**

```rust
#[test]
fn truncate_messages_at_exact_limit() {
    let messages = vec![msg("a"), msg("b"), msg("c")];
    assert_eq!(truncate_messages(&messages, 3).len(), 3);
}

#[test]
fn truncate_messages_beyond_limit() {
    let messages = vec![msg("a"), msg("b")];
    assert_eq!(truncate_messages(&messages, 5).len(), 2);
}

#[test]
fn truncate_messages_empty_input() {
    let messages: Vec<Message> = vec![];
    assert_eq!(truncate_messages(&messages, 3).len(), 0);
}

#[test]
fn truncate_messages_zero_limit() {
    let messages = vec![msg("a"), msg("b")];
    assert_eq!(truncate_messages(&messages, 0).len(), 0);
}
```
