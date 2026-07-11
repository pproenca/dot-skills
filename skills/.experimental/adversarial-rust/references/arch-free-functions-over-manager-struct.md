---
title: Collapse stateless Manager/Service structs into module functions
tags: arch, modules, service-objects, free-functions
---

## Collapse stateless Manager/Service structs into module functions

A fieldless `InvoiceManager`/`TaxService` struct whose methods take `&self` but never read it is a Java class reflex — in Java, functions must live on a class, so stateless behavior gets a stateless object. Rust modules already namespace functions; the struct adds a construction step, an instance to thread through the program, and the false suggestion that there is state or an identity worth holding. Flatten it: the module is the "service", the functions are its API. Keep a struct only when there is real state (a pool, a cache, config loaded once) — and then the fields, not the name `Manager`, justify it.

**Incorrect (a class with no state):**

```rust
pub struct TaxCalculator;

impl TaxCalculator {
    pub fn new() -> Self { TaxCalculator }
    pub fn vat(&self, net: Decimal, rate: Rate) -> Decimal {
        net * rate.as_decimal()
    }
}
// callers: let calc = TaxCalculator::new(); calc.vat(net, rate);
```

**Correct (the module is the namespace):**

```rust
pub mod tax {
    use super::{Decimal, Rate};

    pub fn vat(net: Decimal, rate: Rate) -> Decimal {
        net * rate.as_decimal()
    }
}
// callers: tax::vat(net, rate);
```

Reference: [The Rust Book — Defining Modules to Control Scope and Privacy](https://doc.rust-lang.org/book/ch07-02-defining-modules-to-control-scope-and-privacy.html)
