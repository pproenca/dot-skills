---
title: Use Explicit Module Declarations in lib.rs
impact: HIGH
impactDescription: Explicit declarations make module structure visible and prevent accidental public exposure
tags: mod, modules, declarations, visibility
---

## Use Explicit Module Declarations in lib.rs

Declare all modules explicitly in lib.rs and re-export public APIs using `pub use`. This makes the crate's structure and public API immediately visible.

**Incorrect (problematic pattern):**

```rust
// Files just exist without clear organization
// lib.rs is empty or minimal - structure unclear
// Users must guess what's public

// lib.rs
pub mod types;  // Is everything public?
pub mod reader; // What's the actual API?
```

**Correct (recommended pattern):**

```rust
// lib.rs - clear module declarations and re-exports
mod types;
mod reader;
mod internal_helpers;  // Private module

// Re-export public API
pub use types::{CpuStat, MemInfo, PidInfo};
pub use reader::ProcReader;

// Conditional compilation for tests
#[cfg(test)]
mod test;
```

```rust
// This pattern makes the public API explicit:
// - Users see exactly what's exported
// - Internal modules stay private
// - Refactoring internals won't break users
```

**When NOT to use:**
- Tiny crates with only 1-2 public items
