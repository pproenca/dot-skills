---
title: Split the god-struct of Options by lifecycle stage
tags: type, typestate, god-struct, lifecycle
---

## Split the god-struct of Options by lifecycle stage

One `Order` struct where `payment_id`, `shipped_at`, and `tracking_number` are all `Option` because "they're set later" is several types flattened into one — the OO habit of a single entity class mutated through its lifecycle. Every stage of the code then trusts comments instead of types ("shipped orders always have tracking") and cashes that trust as `.unwrap()`. Split the struct by stage: each stage's type holds exactly the fields that exist then, non-optional, and a stage transition is a function consuming the old stage and returning the new one — an illegal transition becomes a type error.

**Incorrect (one struct, every stage, fields "set by now"):**

```rust
struct Order {
    items: Vec<LineItem>,
    payment_id: Option<PaymentId>,     // Some after payment
    shipped_at: Option<DateTime<Utc>>, // Some after shipping
    tracking: Option<String>,          // "always Some when shipped"
}
```

**Correct (a type per stage, transitions consume):**

```rust
struct DraftOrder { items: Vec<LineItem> }
struct PaidOrder { items: Vec<LineItem>, payment_id: PaymentId }
struct ShippedOrder { payment_id: PaymentId, shipped_at: DateTime<Utc>, tracking: String }

impl DraftOrder {
    fn pay(self, payment_id: PaymentId) -> PaidOrder {
        PaidOrder { items: self.items, payment_id }
    }
}
```

**When NOT to split:** the optionals are genuinely independent optional attributes (a user's `middle_name`), not stages of a lifecycle — the smell is `Option`s that become `Some` *together*, in a fixed order.

Reference: [Cliff L. Biffle — The Typestate Pattern in Rust](https://cliffle.com/blog/rust-typestate/)
