---
title: Use enumerate Instead of Manual Index Tracking
impact: LOW-MEDIUM
impactDescription: eliminates off-by-one errors, clearer intent
tags: iter, enumerate, index, loops, safety
---

## Use enumerate Instead of Manual Index Tracking

Use `.enumerate()` to get indices alongside values. Avoid manual counter variables that can drift out of sync.

**Incorrect (manual index tracking):**

```rust
fn find_first_error(logs: &[LogEntry]) -> Option<usize> {
    let mut index = 0;
    for log in logs {
        if log.level == Level::Error {
            return Some(index);
        }
        index += 1;  // Easy to forget, or place in wrong spot
    }
    None
}

fn print_numbered_list(items: &[String]) {
    let mut i = 1;
    for item in items {
        println!("{}. {}", i, item);
        i += 1;
    }
}
```

**Correct (enumerate):**

```rust
fn find_first_error(logs: &[LogEntry]) -> Option<usize> {
    for (index, log) in logs.iter().enumerate() {
        if log.level == Level::Error {
            return Some(index);
        }
    }
    None
}

// Even better - use iterator method
fn find_first_error(logs: &[LogEntry]) -> Option<usize> {
    logs.iter().position(|log| log.level == Level::Error)
}

fn print_numbered_list(items: &[String]) {
    for (i, item) in items.iter().enumerate() {
        println!("{}. {}", i + 1, item);
    }
}
```

**Related iterator methods:**

```rust
// Find index of first match
iter.position(|x| x.is_valid())

// Find index of last match
iter.rposition(|x| x.is_valid())

// Get (index, value) pairs
iter.enumerate()
```

Reference: [enumerate - Rust Standard Library](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.enumerate)
