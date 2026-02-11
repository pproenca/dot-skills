---
title: Keep Crate Structure Flat
impact: MEDIUM
impactDescription: Flat structures reduce cognitive overhead and make files easy to locate
tags: org, flat, structure, simplicity
---

## Keep Crate Structure Flat

Place module files directly in src/ directory rather than creating deep hierarchies. Use subdirectories only for complex modules that need multiple files.

**Incorrect (problematic pattern):**

```text
crate/src/
├── core/
│   └── types/
│       └── definitions/
│           └── user_types.rs    # 4 levels deep!
├── readers/
│   └── filesystem/
│       └── proc/
│           └── reader.rs        # 4 levels deep!
└── lib.rs
```text

**Correct (recommended pattern):**

```
crate/src/
├── lib.rs              # Module declarations
├── types.rs            # Type definitions
├── reader.rs           # Main reader logic
├── errors.rs           # Error types
├── test.rs             # Tests
└── complex_module/     # Only when needed
    ├── mod.rs
    └── subcomponent.rs
```

```rust
// lib.rs - flat and simple
mod types;
mod reader;
mod errors;

pub use types::*;
pub use reader::*;
pub use errors::*;

#[cfg(test)]
mod test;
```

**When NOT to use:**
- When a module genuinely has 5+ closely related files
- When organizing platform-specific code (e.g., `open_source/`, `platform/`)
