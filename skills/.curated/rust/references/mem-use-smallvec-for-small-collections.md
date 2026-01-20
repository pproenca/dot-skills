---
title: Use SmallVec for Small Collections
impact: CRITICAL
impactDescription: eliminates heap allocation for typical cases
tags: mem, smallvec, stack, allocation, inline
---

## Use SmallVec for Small Collections

`SmallVec` stores small arrays inline on the stack, falling back to heap only when exceeded. Use it when most instances stay below a threshold.

**Incorrect (always heap allocates):**

```rust
fn get_user_roles(user: &User) -> Vec<Role> {
    let mut roles = Vec::new();  // Heap allocation
    if user.is_admin {
        roles.push(Role::Admin);
    }
    roles.push(Role::User);  // Typical case: 1-2 roles
    roles
}
```

**Correct (stack allocation for typical case):**

```rust
use smallvec::SmallVec;

fn get_user_roles(user: &User) -> SmallVec<[Role; 4]> {
    let mut roles = SmallVec::new();  // Stack allocated up to 4 elements
    if user.is_admin {
        roles.push(Role::Admin);
    }
    roles.push(Role::User);  // No heap allocation
    roles
}
```

**When to use SmallVec:**
- Collections that are usually small (< 8 elements)
- Hot paths where allocation overhead matters
- When you can profile the typical size

**When NOT to use:**
- Large or variable-size collections
- When SmallVec's size check overhead outweighs benefits

Reference: [smallvec crate documentation](https://docs.rs/smallvec)
