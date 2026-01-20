---
title: Derive Common Traits for Public Types
impact: HIGH
impactDescription: enables standard library integration, improves debugging
tags: api, derive, traits, debug, clone, eq
---

## Derive Common Traits for Public Types

Derive standard traits (`Debug`, `Clone`, `PartialEq`, etc.) for public types. This enables users to debug, compare, and use types with standard library containers.

**Incorrect (missing common traits):**

```rust
pub struct User {
    pub id: u64,
    pub name: String,
    pub email: String,
}

fn main() {
    let user = User { id: 1, name: "alice".into(), email: "a@b.com".into() };
    // println!("{:?}", user);  // Error: Debug not implemented
    // let users: HashSet<User>;  // Error: Hash not implemented
    // if user1 == user2 {}  // Error: PartialEq not implemented
}
```

**Correct (derive common traits):**

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct User {
    pub id: u64,
    pub name: String,
    pub email: String,
}

fn main() {
    let user = User { id: 1, name: "alice".into(), email: "a@b.com".into() };
    println!("{:?}", user);  // Works
    let users: HashSet<User> = HashSet::new();  // Works
    let user2 = user.clone();  // Works
    assert_eq!(user, user2);  // Works
}
```

**Common trait checklist:**

| Trait | Derive When | Note |
|-------|-------------|------|
| `Debug` | Always for public types | Enables `{:?}` formatting |
| `Clone` | Type can be duplicated | Required for many APIs |
| `PartialEq` | Type can be compared | Enables `==` operator |
| `Eq` | Equality is reflexive | Required by `Hash` |
| `Hash` | Type used in HashMap/HashSet | Requires `Eq` |
| `Default` | Type has sensible default | Enables `Default::default()` |

Reference: [Common Traits - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/interoperability.html#types-eagerly-implement-common-traits-c-common-traits)
