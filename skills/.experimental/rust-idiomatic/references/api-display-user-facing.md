---
title: Implement Display for User-Facing Types
impact: MEDIUM
impactDescription: enables format!, println!, and .to_string() for error messages and logs
tags: api, display, formatting, user-facing, trait
---

## Implement Display for User-Facing Types

Implement `std::fmt::Display` for types that appear in user-facing output (error messages, CLI output, log entries). Display is the standard trait for human-readable formatting and is required by the `Error` trait.

**Incorrect (Debug output shown to users):**

```rust
#[derive(Debug)]
pub struct RateLimitError {
    pub limit_name: String,
    pub resets_at: DateTime<Utc>,
}
// User sees: RateLimitError { limit_name: "codex", resets_at: ... }
```

**Correct (Display provides human-readable output):**

```rust
#[derive(Debug)]
pub struct RateLimitError {
    pub limit_name: String,
    pub resets_at: DateTime<Utc>,
}

impl std::fmt::Display for RateLimitError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "rate limit exceeded for {}. Try again at {}",
            self.limit_name,
            self.resets_at.format("%-I:%M %p")
        )
    }
}
```
