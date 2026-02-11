---
title: Use HashMap for Key-Value Lookups
impact: HIGH
impactDescription: O(n) to O(1) per lookup
tags: ds, hashmap, lookup, key-value, performance
---

## Use HashMap for Key-Value Lookups

When you need to look up values by key, use `HashMap` instead of iterating through a `Vec` of tuples or structs.

**Incorrect (O(n) per lookup):**

```rust
fn get_user_by_id(users: &[(u64, User)], id: u64) -> Option<&User> {
    users.iter().find(|(uid, _)| *uid == id).map(|(_, u)| u)
}

fn process_orders(users: &[(u64, User)], orders: &[Order]) {
    for order in orders {
        if let Some(user) = get_user_by_id(users, order.user_id) {  // O(n) each
            process(user, order);
        }
    }
}
```

**Correct (O(1) per lookup):**

```rust
use std::collections::HashMap;

fn process_orders(users: &HashMap<u64, User>, orders: &[Order]) {
    for order in orders {
        if let Some(user) = users.get(&order.user_id) {  // O(1) each
            process(user, order);
        }
    }
}
```

**When to use Vec of tuples:**
- Small collections (< 10 elements)
- Iteration order matters
- Keys are not `Hash` + `Eq`

Reference: [std::collections documentation](https://doc.rust-lang.org/std/collections/)
