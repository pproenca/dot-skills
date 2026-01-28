---
title: Organize by feature with mod.rs files
impact: MEDIUM
impactDescription: Feature-based organization improves code navigation and maintainability
tags: org, modules, features
---

# Organize by feature with mod.rs files

Group related functionality in directories with `mod.rs` files.

## Why This Matters

- Related code is co-located
- Easy to understand feature scope
- Clear module boundaries
- Supports encapsulation

**Incorrect (flat structure with many files):**

```text
src/
├── lib.rs
├── git_clone.rs
├── git_status.rs
├── git_commit.rs
├── shell_exec.rs
├── shell_parse.rs
└── file_read.rs
```

**Correct (feature-based organization):**

```text
src/
├── lib.rs
├── config/
│   ├── mod.rs
│   ├── loader.rs
│   └── validation.rs
├── tools/
│   ├── mod.rs
│   ├── git.rs
│   ├── shell.rs
│   └── file_ops.rs
└── sandboxing/
    ├── mod.rs
    ├── linux.rs
    └── macos.rs
```

## mod.rs Pattern

```rust
// src/tools/mod.rs
//! Tool implementations for the agent.

mod git;
mod shell;
mod file_ops;

// Re-export public API
pub use git::GitTool;
pub use shell::ShellTool;
pub use file_ops::FileOps;

// Internal shared utilities
pub(crate) mod utils;
```

## lib.rs References

```rust
// src/lib.rs
pub mod config;
pub mod tools;
pub mod sandboxing;
```

## When to Use Directories vs Single Files

**Use directories when:**
- Feature has 3+ related components
- Clear sub-features exist
- Shared internal utilities needed

**Use single files when:**
- Feature is cohesive and small
- No logical sub-divisions
- Under ~300 lines
