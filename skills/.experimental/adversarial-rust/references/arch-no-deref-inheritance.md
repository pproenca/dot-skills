---
title: Avoid simulating inheritance with Deref — delegate or use a trait
tags: arch, deref, inheritance, composition
---

## Avoid simulating inheritance with Deref — delegate or use a trait

`impl Deref for Admin { type Target = User; }` so that `admin.email()` "inherits" `User`'s methods is the OO-inheritance habit smuggled through an operator meant for smart pointers. It lies to every reader (`*admin` is not a dereference in any pointer sense), breaks the moment `Admin` needs a method whose name collides with `User`'s, and doesn't participate in trait bounds — `Admin` still isn't a `User` where one is required. Rust models an is-a relationship with a trait, and a has-a relationship with explicit delegation.

**Incorrect (Deref as pseudo-inheritance):**

```rust
use std::ops::Deref;

struct Admin { user: User, scopes: Vec<Scope> }

impl Deref for Admin {
    type Target = User;
    fn deref(&self) -> &User { &self.user }
}
```

**Correct (delegate the methods you actually share):**

```rust
struct Admin { user: User, scopes: Vec<Scope> }

impl Admin {
    fn email(&self) -> &str { self.user.email() }
}
```

If several types share the behavior, define the trait that names it (`trait HasEmail { fn email(&self) -> &str; }`) and implement it for each — that is the relationship inheritance was approximating, expressed in the mechanism Rust checks.

Reference: [Rust Design Patterns — `Deref` polymorphism (anti-pattern)](https://rust-unofficial.github.io/patterns/anti_patterns/deref.html)
