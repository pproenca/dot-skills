---
title: Use Cow for Conditional Ownership
impact: CRITICAL
impactDescription: avoids allocation when borrowed data suffices
tags: own, cow, borrowing, conditional-ownership, lifetime
---

## Use Cow for Conditional Ownership

Use `Cow<'_, str>` (or `Cow<'_, [T]>`) when a function returns either borrowed or owned data depending on runtime conditions. This avoids allocating when the input can be returned as-is while still supporting the case where transformation requires a new allocation.

**Incorrect (always allocates a new String):**

```rust
fn normalize_path(path: &str) -> String {
    if path.contains("//") {
        path.replace("//", "/")
    } else {
        path.to_string()
    }
}
```

**Correct (borrows when no transformation needed):**

```rust
use std::borrow::Cow;

fn normalize_path(path: &str) -> Cow<'_, str> {
    if path.contains("//") {
        Cow::Owned(path.replace("//", "/"))
    } else {
        Cow::Borrowed(path)
    }
}
```
