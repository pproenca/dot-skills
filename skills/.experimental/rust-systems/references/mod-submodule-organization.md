---
title: Use mod.rs for Multi-File Modules
impact: MEDIUM
impactDescription: Subdirectories with mod.rs organize complex modules while maintaining clear boundaries
tags: mod, modules, organization, mod-rs
---

## Use mod.rs for Multi-File Modules

When a module needs multiple implementation files, create a subdirectory with mod.rs as the root. Sibling .rs files are declared in mod.rs.

**Incorrect (problematic pattern):**

```rust
// Trying to handle complex module in single file
// src/btrfs_api.rs - 2000+ lines with multiple concerns

pub struct BtrfsApi { ... }
pub struct BtrfsUtils { ... }  // Should be separate
pub fn run_tests() { ... }     // Should be separate

// Or using the 2018 edition file naming that's less clear
// src/btrfs_api.rs (main file)
// src/btrfs_api/utils.rs (submodule - confusing path)
```text

**Correct (recommended pattern):**

```
src/btrfs_api/
├── mod.rs          # Module root - declarations
├── utils.rs        # Utility functions
├── test.rs         # Module tests
└── sudotest.rs     # Tests requiring privileges
```

```rust
// btrfs_api/mod.rs
mod utils;
mod test;

pub use utils::compress_extent;

pub struct BtrfsApi {
    // ...
}

impl BtrfsApi {
    pub fn new() -> Self { ... }
}

#[cfg(test)]
mod test;

#[cfg(test)]
#[cfg(feature = "sudo_tests")]
mod sudotest;
```

```rust
// btrfs_api/utils.rs
pub fn compress_extent(data: &[u8]) -> Vec<u8> {
    // Implementation
}
```

**When NOT to use:**
- Simple modules that fit comfortably in a single file (< 500 lines)
- When using Rust 2018 edition's `module_name.rs` + `module_name/` style
