---
title: Use extend() for Bulk Append
impact: HIGH
impactDescription: single reallocation instead of N
tags: iter, extend, append, push, allocation
---

## Use extend() for Bulk Append

When appending multiple elements, `extend()` preallocates and appends in one operation. Multiple `push()` calls may trigger repeated reallocations.

**Incorrect (may reallocate multiple times):**

```rust
fn merge_users(mut existing: Vec<User>, new_users: &[User]) -> Vec<User> {
    for user in new_users {
        existing.push(user.clone());  // May reallocate each time
    }
    existing
}
```

**Correct (single reallocation):**

```rust
fn merge_users(mut existing: Vec<User>, new_users: &[User]) -> Vec<User> {
    existing.extend(new_users.iter().cloned());  // Preallocates
    existing
}
```

**Alternative (append for owned Vecs):**

```rust
fn merge_users(mut existing: Vec<User>, mut new_users: Vec<User>) -> Vec<User> {
    existing.append(&mut new_users);  // Moves elements, empties new_users
    existing
}
```

**extend advantages:**
- Uses `size_hint()` to preallocate
- Works with any iterator
- Avoids consuming the source collection

Reference: [Vec::extend documentation](https://doc.rust-lang.org/std/vec/struct.Vec.html#method.extend)
