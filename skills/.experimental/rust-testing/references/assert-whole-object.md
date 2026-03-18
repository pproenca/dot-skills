---
title: Compare Entire Objects Not Individual Fields
impact: CRITICAL
impactDescription: catches 100% of unexpected field changes that field-by-field checks miss
tags: assert, deep-equals, struct-comparison, regression
---

## Compare Entire Objects Not Individual Fields

Perform `assert_eq!()` on entire objects rather than asserting individual fields. When a struct gains a new field or an existing field changes unexpectedly, a whole-object comparison catches it immediately. Field-by-field assertions silently ignore fields they do not check.

**Incorrect (field-by-field misses unexpected changes):**

```rust
#[test]
fn test_session_configured_event() {
    let event = build_session_event();
    assert_eq!(event.model, "gpt-4");
    assert_eq!(event.sandbox_policy, SandboxPolicy::Allowlist);
    // If event.temperature changes from 0.7 to 1.0, this test still passes
}
```

**Correct (whole-object catches all field changes):**

```rust
#[test]
fn test_session_configured_event() {
    let event = build_session_event();
    let expected = SessionConfiguredEvent {
        model: "gpt-4".into(),
        sandbox_policy: SandboxPolicy::Allowlist,
        temperature: 0.7,
        ..Default::default()
    };
    assert_eq!(event, expected);
    // Any field change causes a clear diff
}
```
