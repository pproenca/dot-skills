---
title: Create Custom Strategies for Domain Types
impact: HIGH
impactDescription: generates realistic test data for domain models
tags: prop, proptest, strategies, domain-types, generators
---

## Create Custom Strategies for Domain Types

Create custom proptest strategies for domain types to generate valid test data. This ensures generated values respect business invariants.

**Incorrect (random values violate invariants):**

```rust
proptest! {
    #[test]
    fn test_order(
        quantity in any::<i32>(),   // Negative quantities?
        price in any::<f64>(),       // NaN? Negative?
        email in ".*"                // Invalid emails?
    ) {
        let order = Order::new(quantity, price, &email);
        // Order::new panics on invalid inputs!
    }
}
```

**Correct (custom strategies enforce invariants):**

```rust
use proptest::prelude::*;

// Strategy for valid email addresses
fn valid_email() -> impl Strategy<Value = String> {
    ("[a-z]{3,10}", "[a-z]{2,8}", "[a-z]{2,4}")
        .prop_map(|(user, domain, tld)| format!("{}@{}.{}", user, domain, tld))
}

// Strategy for valid money amounts
fn valid_price() -> impl Strategy<Value = Decimal> {
    (1i64..1_000_000, 0u8..100)
        .prop_map(|(dollars, cents)| Decimal::new(dollars * 100 + cents as i64, 2))
}

// Strategy for valid order quantities
fn valid_quantity() -> impl Strategy<Value = u32> {
    1u32..1000
}

// Composite strategy for Order
fn valid_order() -> impl Strategy<Value = Order> {
    (valid_quantity(), valid_price(), valid_email())
        .prop_map(|(quantity, price, email)| {
            Order::new(quantity, price, &email).unwrap()
        })
}

proptest! {
    #[test]
    fn order_total_is_positive(order in valid_order()) {
        prop_assert!(order.total() > Decimal::ZERO);
    }

    #[test]
    fn order_total_equals_quantity_times_price(order in valid_order()) {
        let expected = order.price * Decimal::from(order.quantity);
        prop_assert_eq!(order.total(), expected);
    }
}
```

**Strategy for nested types:**

```rust
fn valid_user() -> impl Strategy<Value = User> {
    (
        "[A-Z][a-z]{2,15}",           // First name
        "[A-Z][a-z]{2,15}",           // Last name
        valid_email(),
        18u8..100,                     // Age
    ).prop_map(|(first, last, email, age)| {
        User { first_name: first, last_name: last, email, age }
    })
}

fn valid_order_with_user() -> impl Strategy<Value = (User, Order)> {
    valid_user().prop_flat_map(|user| {
        valid_order().prop_map(move |order| (user.clone(), order))
    })
}
```

**Derive Arbitrary for simple structs:**

```rust
use proptest_derive::Arbitrary;

#[derive(Debug, Arbitrary)]
struct Point {
    #[proptest(strategy = "-1000.0..1000.0")]
    x: f64,
    #[proptest(strategy = "-1000.0..1000.0")]
    y: f64,
}
```

Reference: [proptest - Generating Structured Data](https://proptest-rs.github.io/proptest/proptest/tutorial/compound-strategies.html)
