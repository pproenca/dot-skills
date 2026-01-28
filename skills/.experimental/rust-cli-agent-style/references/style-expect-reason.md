---
title: Use #[expect] with reason for lint suppression
impact: MEDIUM
impactDescription: Documents why lints are suppressed and ensures suppressions are still needed
tags: style, lints, documentation
---

# Use #[expect] with reason for lint suppression

When suppressing lints, use `#[expect(lint, reason = "...")]` instead of `#[allow]`.

## Why This Matters

- Documents WHY the lint is suppressed
- Warns when suppression is no longer needed
- Better than silent `#[allow]`
- Rust 1.81+ feature

**Incorrect (avoid this pattern):**

```rust
#[allow(clippy::print_stderr)
fn output_error(msg: &str) {
    eprintln!("Error: {}", msg);
}

#[allow(dead_code)
fn unused_helper() { }

#[allow(clippy::unwrap_used)
fn infallible_parse() {
    let _: u32 = "42".parse().unwrap();
}
```

**Correct (recommended):**

```rust
#[expect(clippy::print_stderr, reason = "TUI output after terminal restore")
fn output_error(msg: &str) {
    eprintln!("Error: {}", msg);
}

#[expect(dead_code, reason = "used in integration tests only")
fn test_helper() { }

#[expect(clippy::unwrap_used, reason = "static string always parses as u32")
fn infallible_parse() {
    let _: u32 = "42".parse().unwrap();
}
```

## #[expect] vs #[allow

| Attribute | Behavior |
|-----------|----------|
| `#[allow]` | Silently suppresses lint, no warning if unused |
| `#[expect]` | Suppresses lint, warns if lint no longer triggers |

## When Suppression Is Removed

If you fix the code and the lint no longer applies:

```rust
// This will warn: "this lint expectation is unfulfilled"
#[expect(clippy::unwrap_used, reason = "...")
fn now_uses_proper_error_handling() {
    let _ = "42".parse::<u32>().ok();  // No unwrap!
}
```

## Module-Level Expects

```rust
// At module level for broader scope
#![expect(clippy::module_inception, reason = "deliberate module structure")
```
