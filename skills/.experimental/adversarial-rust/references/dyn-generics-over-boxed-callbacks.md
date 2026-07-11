---
title: Take impl Trait parameters instead of boxing by habit
tags: dyn, generics, impl-trait, closures
---

## Take impl Trait parameters instead of boxing by habit

`Box<dyn Fn(&Order) -> bool>` as a parameter type — or `&dyn Formatter` where one concrete formatter arrives — is boxing as a reflex, imported from languages where every function value is heap-allocated anyway. Rust callers then pay an allocation and dynamic dispatch for what generics do statically: `impl Trait` in argument position monomorphizes, inlines, and accepts a bare closure with no `Box::new` wrapping at every call site.

**Incorrect (allocation and vtable for a compile-time-known closure):**

```rust
fn retain_matching(orders: &mut Vec<Order>, pred: Box<dyn Fn(&Order) -> bool>) {
    orders.retain(|o| pred(o));
}
// caller: retain_matching(&mut orders, Box::new(|o| o.total > threshold));
```

**Correct (generic — zero ceremony at the call site):**

```rust
fn retain_matching(orders: &mut Vec<Order>, pred: impl Fn(&Order) -> bool) {
    orders.retain(|o| pred(o));
}
// caller: retain_matching(&mut orders, |o| o.total > threshold);
```

**When dyn IS right:** the type genuinely can't be static — storing heterogeneous callbacks in one collection, returning one of several closure types from a branch, keeping a struct field non-generic to contain compile times, or crossing an ABI/object-safety boundary. The test is whether the concrete type is known at the call site; when it is, let monomorphization have it.

Reference: [The Rust Book — Traits: `impl Trait` syntax](https://doc.rust-lang.org/book/ch10-02-traits.html#traits-as-parameters)
