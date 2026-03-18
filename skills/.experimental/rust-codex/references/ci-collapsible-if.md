---
title: Collapse Nested if Statements
impact: LOW-MEDIUM
impactDescription: prevents clippy CI failure (clippy::collapsible_if)
tags: ci, clippy, collapsible-if, style
---

## Collapse Nested if Statements

Always collapse nested `if` statements into a single `if` with `&&` per the `clippy::collapsible_if` lint. The codebase enforces this lint in CI. Nested ifs that can be combined are flagged as errors.

**Incorrect (nested ifs that clippy flags):**

```rust
fn should_retry(err: &CodexErr, attempt: u32) -> bool {
    if err.is_retryable() {
        if attempt < MAX_RETRIES {
            return true;
        }
    }
    false
}
```

**Correct (collapsed into single condition):**

```rust
fn should_retry(err: &CodexErr, attempt: u32) -> bool {
    if err.is_retryable() && attempt < MAX_RETRIES {
        return true;
    }
    false
}
```
