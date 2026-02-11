---
title: Prefix Getter Functions with get_
impact: MEDIUM
impactDescription: Consistent prefixes make API predictable and self-documenting
tags: name, getters, prefix, api-design
---

## Prefix Getter Functions with get_

Functions that retrieve values use the `get_` prefix consistently. This distinguishes retrieval from computation or mutation.

**Incorrect (problematic pattern):**

```rust
impl System {
    fn hostname(&self) -> Result<String> { ... }
    fn unix_timestamp(&self) -> u64 { ... }
    fn backtrace(&self) -> Option<&Backtrace> { ... }
    fn os_release(&self) -> &str { ... }
}
```

**Correct (recommended pattern):**

```rust
impl System {
    fn get_hostname(&self) -> Result<String> { ... }
    fn get_unix_timestamp(&self) -> u64 { ... }
    fn get_backtrace(&self) -> Option<&Backtrace> { ... }
    fn get_os_release(&self) -> &str { ... }
}

// Also applies to standalone functions
pub fn get_page_size() -> u64 { ... }
pub fn get_boot_time() -> SystemTime { ... }
```

**Exception - field accessors:**
```rust
// Simple field access can omit get_ for ergonomics
impl CpuStat {
    pub fn user_usec(&self) -> Option<u64> {
        self.user_usec
    }
}
```

**When NOT to use:**
- Simple field accessors on newtype wrappers
- Methods following established Rust conventions (e.g., `len()`, `is_empty()`)
- Iterator methods (`next()`, `peek()`)
