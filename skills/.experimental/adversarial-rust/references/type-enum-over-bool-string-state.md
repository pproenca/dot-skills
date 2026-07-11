---
title: Replace boolean and string state flags with one enum
tags: type, enums, state-machine, invalid-states
---

## Replace boolean and string state flags with one enum

`is_active: bool, is_suspended: bool, status: String` is how languages without sum types encode a state machine — and it makes the impossible representable: active *and* suspended, a status string nobody matches on ("Suspended" vs "suspended"). Every reader must re-derive which combinations are legal, and no compiler checks them. One enum whose variants carry their state's data makes the illegal combinations unrepresentable and turns every state decision into an exhaustive `match` the compiler completes for you when a variant is added.

**Incorrect (three fields, most combinations meaningless):**

```rust
struct Subscription {
    is_active: bool,
    is_cancelled: bool,
    cancelled_at: Option<DateTime<Utc>>, // "should be Some when cancelled"
    trial_ends: Option<DateTime<Utc>>,   // "only meaningful during trial"
}
```

**Correct (each state owns exactly its data):**

```rust
enum Subscription {
    Trial { ends: DateTime<Utc> },
    Active { renews: DateTime<Utc> },
    Cancelled { at: DateTime<Utc> },
}
```

The refactor's payoff shows at the call sites: `if sub.is_active && !sub.is_cancelled` chains collapse into `match`, and the `cancelled_at.unwrap()` "it should be set by now" calls disappear because the data is only reachable in the state where it exists.

Reference: [corrode (Matthias Endler) — Making Illegal States Unrepresentable](https://corrode.dev/blog/illegal-state/)
