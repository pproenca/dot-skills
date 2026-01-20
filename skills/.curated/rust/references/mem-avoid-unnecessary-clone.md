---
title: Avoid Unnecessary Clone Calls
impact: CRITICAL
impactDescription: eliminates heap allocations per call
tags: mem, clone, allocation, heap, performance
---

## Avoid Unnecessary Clone Calls

Every `.clone()` call on heap-allocated types triggers a new allocation and memory copy. Pass references instead when ownership transfer is not required.

**Incorrect (allocates on every call):**

```rust
fn process_user(user: User) {
    validate(&user);
    save(&user);
}

fn main() {
    let user = fetch_user();
    process_user(user.clone());  // Allocates entire User struct
    process_user(user.clone());  // Allocates again
}
```

**Correct (zero allocations):**

```rust
fn process_user(user: &User) {
    validate(user);
    save(user);
}

fn main() {
    let user = fetch_user();
    process_user(&user);  // No allocation
    process_user(&user);  // No allocation
}
```

**When clone IS appropriate:**
- When you need to mutate a copy independently
- When ownership must transfer to another thread
- When the type is `Copy` (no heap allocation)

Reference: [Heap Allocations - The Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html)
