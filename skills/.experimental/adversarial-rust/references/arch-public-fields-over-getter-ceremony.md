---
title: Expose plain data as public fields, not getter/setter pairs
tags: arch, encapsulation, getters, structs
---

## Expose plain data as public fields, not getter/setter pairs

`get_name()`/`set_name()` on every field is C#/Java property ceremony, where accessors are the price of ever adding logic later. Rust doesn't pay that price: a plain data struct with `pub` fields can move to private-field-plus-method later as an ordinary (source-breaking, compiler-guided) refactor, and ownership already prevents the aliased-mutation surprises accessors guard against elsewhere. Accessors in Rust are for types with an *invariant* to protect — and even then the convention is `name()`, not `get_name()`.

**Incorrect (ceremony with nothing to protect):**

```rust
pub struct ShippingAddress { street: String, city: String }

impl ShippingAddress {
    pub fn get_street(&self) -> &str { &self.street }
    pub fn set_street(&mut self, s: String) { self.street = s; }
    pub fn get_city(&self) -> &str { &self.city }
    pub fn set_city(&mut self, c: String) { self.city = c; }
}
```

**Correct (plain data is plain):**

```rust
pub struct ShippingAddress { pub street: String, pub city: String }
```

**When accessors ARE right:** the type maintains an invariant (a `Balance` that must never go negative, a sorted `Vec` that must stay sorted). Then keep fields private, validate in the mutating methods, and name getters without the `get_` prefix per C-GETTER.

Reference: [Rust API Guidelines — C-GETTER](https://rust-lang.github.io/api-guidelines/naming.html#getter-names-follow-rust-convention-c-getter)
