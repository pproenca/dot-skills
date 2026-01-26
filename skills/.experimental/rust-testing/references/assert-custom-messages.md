---
title: Add Context to Assertions with Custom Messages
impact: MEDIUM
impactDescription: provides context for debugging failures
tags: assert, messages, context, debugging, diagnostics
---

## Add Context to Assertions with Custom Messages

Add custom messages to assertions explaining what's being tested. Generic assertions require reading code to understand failures.

**Incorrect (no context in assertion):**

```rust
#[test]
fn test_user_permissions() {
    let user = create_admin_user();

    assert!(user.can_edit());      // What if this fails?
    assert!(user.can_delete());    // Which assertion failed?
    assert!(user.can_admin());     // Need to read code to understand
}

#[test]
fn test_order_validation() {
    for order in test_orders() {
        assert!(order.is_valid());  // Which order failed?
    }
}
```

**Correct (descriptive assertion messages):**

```rust
#[test]
fn test_user_permissions() {
    let user = create_admin_user();

    assert!(user.can_edit(), "Admin user should have edit permission");
    assert!(user.can_delete(), "Admin user should have delete permission");
    assert!(user.can_admin(), "Admin user should have admin permission");
}

#[test]
fn test_order_validation() {
    for order in test_orders() {
        assert!(
            order.is_valid(),
            "Order {} should be valid: {:?}",
            order.id,
            order
        );
    }
}
```

**Format strings with values:**

```rust
#[test]
fn test_discount_calculation() {
    let order = Order::new(150.0);
    let discount = order.calculate_discount();

    assert_eq!(
        discount,
        15.0,
        "Order of ${:.2} should get 10% discount (${:.2}), got ${:.2}",
        order.total,
        order.total * 0.10,
        discount
    );
}

#[test]
fn test_bounds() {
    let values = compute_values();

    for (i, value) in values.iter().enumerate() {
        assert!(
            *value >= 0.0 && *value <= 1.0,
            "Value at index {} should be in [0, 1], got {}",
            i,
            value
        );
    }
}
```

**Using assert! vs assert_eq! messages:**

```rust
// assert! - good for boolean conditions with context
assert!(
    user.age >= 18,
    "User {} must be 18+, but age is {}",
    user.name,
    user.age
);

// assert_eq! - good for value comparisons (shows both values automatically)
assert_eq!(
    result.status,
    Status::Active,
    "User {} should be active after activation",
    user.id
);
```

**Helper functions for complex assertions:**

```rust
fn assert_user_has_role(user: &User, role: &str) {
    assert!(
        user.roles.contains(&role.to_string()),
        "User {} should have role '{}', but roles are: {:?}",
        user.email,
        role,
        user.roles
    );
}

#[test]
fn test_role_assignment() {
    let user = create_user_with_roles();
    assert_user_has_role(&user, "admin");
    assert_user_has_role(&user, "editor");
}
```

Reference: [The Rust Book - assert! Macro](https://doc.rust-lang.org/book/ch11-01-writing-tests.html#checking-results-with-the-assert-macro)
