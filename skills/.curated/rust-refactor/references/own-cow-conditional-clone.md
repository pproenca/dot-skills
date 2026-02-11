---
title: Use Cow for Conditional Ownership
impact: CRITICAL
impactDescription: avoids clones when mutation is rare, zero-cost when borrowing
tags: own, cow, clone-on-write, conditional, optimization
---

## Use Cow for Conditional Ownership

Use `Cow<'a, T>` (Clone-on-Write) when a function sometimes needs to modify data but usually returns the input unchanged.

**Incorrect (always clones even when unchanged):**

```rust
fn normalize_path(path: &str) -> String {
    if path.contains("//") {
        path.replace("//", "/")  // Clone needed for replacement
    } else {
        path.to_string()  // Unnecessary clone when unchanged
    }
}

fn main() {
    let path = "/home/user/file";  // No normalization needed
    let normalized = normalize_path(path);  // Still clones
}
```

**Correct (clone only when modification needed):**

```rust
use std::borrow::Cow;

fn normalize_path(path: &str) -> Cow<'_, str> {
    if path.contains("//") {
        Cow::Owned(path.replace("//", "/"))  // Clone only when needed
    } else {
        Cow::Borrowed(path)  // Zero-cost borrow
    }
}

fn main() {
    let path = "/home/user/file";
    let normalized = normalize_path(path);  // Returns Cow::Borrowed, no clone
    println!("{}", normalized);  // Cow derefs to &str
}
```

**Benefits:**
- Zero allocation when input is already valid
- Transparent usage via `Deref` implementation
- Explicit about when allocation occurs

**When NOT to use:**
- When modification is always needed
- When the complexity outweighs the performance benefit

Reference: [Cow in std::borrow](https://doc.rust-lang.org/std/borrow/enum.Cow.html)
