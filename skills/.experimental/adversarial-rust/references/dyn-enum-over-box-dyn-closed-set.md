---
title: Use an enum, not Box<dyn Trait>, for a closed set of variants
tags: dyn, enums, trait-objects, dispatch
---

## Use an enum, not Box<dyn Trait>, for a closed set of variants

`Vec<Box<dyn PaymentMethod>>` where the implementors are the three structs *you* wrote in the same crate is the Java-interface reflex — "program to an interface" applied where no third party will ever add a variant. The trait object erases exactly the information you own: no exhaustive `match` (adding `Sepa` can't force every handler to update), a heap allocation and vtable call per element, and any method needing the concrete type grows `as_any()` downcasting ceremony. A closed set is what `enum` *is*; each variant carries its own data and dispatch is a `match` the compiler audits.

**Incorrect (open-world machinery for a closed set):**

```rust
trait PaymentMethod {
    fn authorize(&self, amount: Cents) -> Result<AuthToken, ChargeError>;
}
struct Card { pan: Pan }
struct BankTransfer { iban: Iban }
// all implementors live in this crate; nobody else can add one
fn run(methods: Vec<Box<dyn PaymentMethod>>) { /* ... */ }
```

**Correct (the closed set, stated as one):**

```rust
enum PaymentMethod {
    Card { pan: Pan },
    BankTransfer { iban: Iban },
}

impl PaymentMethod {
    fn authorize(&self, amount: Cents) -> Result<AuthToken, ChargeError> {
        match self {
            PaymentMethod::Card { pan } => authorize_card(pan, amount),
            PaymentMethod::BankTransfer { iban } => authorize_sepa(iban, amount),
        }
    }
}
```

**When dyn IS right:** the set is genuinely open — downstream crates or runtime-loaded plugins supply implementations you cannot enumerate. That is the situation trait objects exist for.

Reference: [The Rust Book — Using Trait Objects That Allow for Values of Different Types](https://doc.rust-lang.org/book/ch18-02-trait-objects.html)
