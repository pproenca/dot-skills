---
title: Use Iterator Chains When Clearer Than Loops
impact: LOW-MEDIUM
impactDescription: Can reduce code by 30-50% for transforms, but overuse hurts readability
tags: idiom, rust, iterators, functional
---

## Use Iterator Chains When Clearer Than Loops

Rust's iterator combinators (`map`, `filter`, `fold`, etc.) can express data transformations more declaratively than loops. However, they're not always clearer—complex chains with multiple closures or stateful operations often become harder to understand than equivalent loops. Choose based on readability, not style preference.

**Incorrect (forced iterator chain hurts clarity):**

```rust
// Too complex - hard to follow the logic
fn process_orders(orders: &[Order]) -> HashMap<CustomerId, Vec<ProcessedOrder>> {
    orders
        .iter()
        .filter(|o| o.status == Status::Pending)
        .filter_map(|o| {
            if let Some(customer) = get_customer(o.customer_id) {
                Some((customer, o))
            } else {
                log::warn!("Unknown customer: {}", o.customer_id);
                None
            }
        })
        .map(|(customer, order)| {
            let processed = process_single_order(order, &customer);
            (customer.id, processed)
        })
        .fold(HashMap::new(), |mut acc, (id, order)| {
            acc.entry(id).or_default().push(order);
            acc
        })
}
```

**Correct (loop is clearer for complex logic):**

```rust
fn process_orders(orders: &[Order]) -> HashMap<CustomerId, Vec<ProcessedOrder>> {
    let mut result: HashMap<CustomerId, Vec<ProcessedOrder>> = HashMap::new();

    for order in orders.iter().filter(|o| o.status == Status::Pending) {
        let Some(customer) = get_customer(order.customer_id) else {
            log::warn!("Unknown customer: {}", order.customer_id);
            continue;
        };

        let processed = process_single_order(order, &customer);
        result.entry(customer.id).or_default().push(processed);
    }

    result
}
```

**Correct (iterator chain for simple transforms):**

```rust
// Clear and concise - good use of iterators
fn get_active_user_emails(users: &[User]) -> Vec<String> {
    users
        .iter()
        .filter(|u| u.is_active)
        .map(|u| u.email.clone())
        .collect()
}

// Sum with filter - straightforward
fn total_revenue(orders: &[Order]) -> Decimal {
    orders
        .iter()
        .filter(|o| o.status == Status::Completed)
        .map(|o| o.total)
        .sum()
}
```

### Guidelines

| Use Iterators When | Use Loops When |
|-------------------|----------------|
| Simple filter/map/collect | Multiple related mutations |
| No side effects needed | Early returns with context |
| Each step is self-contained | Stateful iteration |
| 2-3 combinators max | Complex branching logic |

### Benefits of Knowing Both

- Iterator chains can be lazy and more memory-efficient
- Loops are easier to debug with breakpoints
- Mixing both (filter in iterator, logic in loop) often optimal
