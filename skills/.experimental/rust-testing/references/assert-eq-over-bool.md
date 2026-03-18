---
title: Use assert_eq Over assert with Boolean Expressions
impact: CRITICAL
impactDescription: 3-5x faster debugging with actual vs expected values on failure
tags: assert, diagnostics, assert-eq, failure-messages
---

## Use assert_eq Over assert with Boolean Expressions

Replace `assert!(a == b)` with `assert_eq!(a, b)`. When `assert!` fails, the output is `assertion failed: a == b` with no values. When `assert_eq!` fails, it prints both the expected and actual values, immediately revealing the mismatch.

**Incorrect (boolean assert hides actual values):**

```rust
#[test]
fn test_token_count() {
    let result = count_tokens("hello world");
    assert!(result == 2);
    // Failure: "assertion failed: result == 2" — what was result?
}

#[test]
fn test_model_name() {
    let model = resolve_model(&config);
    assert!(model == "gpt-4");
    // Failure: "assertion failed: model == \"gpt-4\"" — what was model?
}
```

**Correct (assert_eq reveals actual values on failure):**

```rust
#[test]
fn test_token_count() {
    let result = count_tokens("hello world");
    assert_eq!(result, 2);
    // Failure: "left: 3, right: 2" — immediately clear
}

#[test]
fn test_model_name() {
    let model = resolve_model(&config);
    assert_eq!(model, "gpt-4");
    // Failure: "left: \"gpt-3.5\", right: \"gpt-4\"" — exact mismatch shown
}
```
