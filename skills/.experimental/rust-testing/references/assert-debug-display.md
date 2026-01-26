---
title: Implement Debug for Clear Test Failure Messages
impact: MEDIUM
impactDescription: provides actionable information on assertion failure
tags: assert, debug, display, failure-messages, diagnostics
---

## Implement Debug for Clear Test Failure Messages

Derive or implement `Debug` for types used in assertions. Without Debug, assertion failures show unhelpful messages like `assertion failed: (left != right)`.

**Incorrect (no Debug, useless failure message):**

```rust
struct Order {
    id: u64,
    items: Vec<Item>,
    total: f64,
}

#[test]
fn test_order_total() {
    let order = create_order();
    let expected = Order { id: 1, items: vec![], total: 100.0 };

    assert_eq!(order, expected);
    // Failure message: `assertion failed: (left == right)`
    // No information about what's different!
}
```

**Correct (Debug derives, clear failure message):**

```rust
#[derive(Debug, PartialEq)]
struct Order {
    id: u64,
    items: Vec<Item>,
    total: f64,
}

#[derive(Debug, PartialEq)]
struct Item {
    name: String,
    price: f64,
}

#[test]
fn test_order_total() {
    let order = create_order();
    let expected = Order { id: 1, items: vec![], total: 100.0 };

    assert_eq!(order, expected);
    // Failure message shows actual values:
    // left: Order { id: 1, items: [Item { name: "Widget", price: 50.0 }], total: 50.0 }
    // right: Order { id: 1, items: [], total: 100.0 }
}
```

**Custom Debug for better output:**

```rust
use std::fmt;

struct Password(String);

impl fmt::Debug for Password {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Password([REDACTED, len={}])", self.0.len())
    }
}

struct User {
    email: String,
    password: Password,
}

impl fmt::Debug for User {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("User")
            .field("email", &self.email)
            .field("password", &self.password)  // Shows [REDACTED]
            .finish()
    }
}
```

**Using pretty assertions for better diffs:**

```rust
use pretty_assertions::assert_eq;

#[test]
fn test_config_parsing() {
    let actual = parse_config(input);
    let expected = Config { /* ... */ };

    assert_eq!(actual, expected);
    // Shows colored diff highlighting exactly what's different
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
pretty_assertions = "1.4"
```

**Best practices:**

```rust
// Derive Debug for all test-related types
#[derive(Debug, Clone, PartialEq)]
pub struct TestResult {
    status: Status,
    duration_ms: u64,
    output: String,
}

// Use dbg! macro for quick debugging
#[test]
fn test_with_debugging() {
    let value = compute_something();
    dbg!(&value);  // Prints: [src/lib.rs:42] &value = ...
    assert!(value.is_valid());
}
```

Reference: [std::fmt::Debug](https://doc.rust-lang.org/std/fmt/trait.Debug.html)
