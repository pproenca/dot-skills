---
title: Use iter() Over into_iter() When Borrowing
impact: HIGH
impactDescription: preserves original collection
tags: iter, borrow, ownership, into_iter, iterator
---

## Use iter() Over into_iter() When Borrowing

`into_iter()` consumes the collection. If you only need to read elements, use `iter()` (or `iter_mut()` for mutation) to preserve the original.

**Incorrect (consumes collection unnecessarily):**

```rust
fn find_admin(users: Vec<User>) -> Option<User> {
    users.into_iter().find(|u| u.is_admin)  // Vec is consumed
}

fn main() {
    let users = load_users();
    let admin = find_admin(users);
    // users is now invalid - can't reuse
}
```

**Correct (borrows collection):**

```rust
fn find_admin(users: &[User]) -> Option<&User> {
    users.iter().find(|u| u.is_admin)  // Borrows, collection preserved
}

fn main() {
    let users = load_users();
    let admin = find_admin(&users);
    // users is still valid for further use
    let count = users.len();
}
```

**When into_iter IS appropriate:**
- When you need owned values in the result
- When the collection won't be needed again
- When transforming to a different collection type

Reference: [Iterator documentation](https://doc.rust-lang.org/std/iter/trait.Iterator.html)
