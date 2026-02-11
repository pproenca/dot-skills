---
title: Prefer Iterator Methods Over Manual Loops
impact: LOW-MEDIUM
impactDescription: reduces boilerplate, enables compiler optimizations
tags: iter, iterators, loops, functional, map
---

## Prefer Iterator Methods Over Manual Loops

Use iterator adapters like `map`, `filter`, and `fold` instead of manual loops. They're more concise and often better optimized.

**Incorrect (manual loop with mutable accumulator):**

```rust
fn sum_of_squares(numbers: &[i32]) -> i32 {
    let mut sum = 0;
    for n in numbers {
        if *n > 0 {
            sum += n * n;
        }
    }
    sum
}

fn get_active_user_names(users: &[User]) -> Vec<String> {
    let mut names = Vec::new();
    for user in users {
        if user.is_active {
            names.push(user.name.clone());
        }
    }
    names
}
```

**Correct (iterator chains):**

```rust
fn sum_of_squares(numbers: &[i32]) -> i32 {
    numbers.iter()
        .filter(|&&n| n > 0)
        .map(|n| n * n)
        .sum()
}

fn get_active_user_names(users: &[User]) -> Vec<String> {
    users.iter()
        .filter(|u| u.is_active)
        .map(|u| u.name.clone())
        .collect()
}
```

**Benefits:**
- Lazy evaluation - operations fused into single pass
- No manual index management
- Clear intent from method names
- Compiler can vectorize and optimize

**When to use loops:**
- Complex control flow (multiple breaks, continues)
- Mutating multiple things simultaneously
- When iterator chain becomes unreadable

Reference: [Item 9: Consider iterator transforms - Effective Rust](https://www.lurklurk.org/effective-rust/iterators.html)
