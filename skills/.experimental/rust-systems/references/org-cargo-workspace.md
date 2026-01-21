---
title: Use Cargo Workspace for Multi-Crate Projects
impact: HIGH
impactDescription: Enables independent compilation, clear crate boundaries, and faster incremental builds
tags: org, workspace, cargo, project-structure
---

## Use Cargo Workspace for Multi-Crate Projects

Organize related crates in a Cargo workspace with clear separation between binary and library crates. This enables parallel compilation, independent versioning, and enforces clear API boundaries.

**Incorrect (problematic pattern):**

```rust
// Single monolithic crate with all functionality
// src/lib.rs with 50+ modules and 100k+ lines
my_project/
├── Cargo.toml
└── src/
    ├── lib.rs
    ├── collector.rs
    ├── model.rs
    ├── view.rs
    ├── store.rs
    └── ... (many more modules)
```text

**Correct (recommended pattern):**

```toml
# Cargo.toml at workspace root
[workspace]
members = [
    "app/",         # Binary crate
    "common",       # Shared utilities
    "model",        # Data models
    "view",         # UI/presentation
    "store",        # Persistence
    "procfs",       # Linux procfs reader
    "cgroupfs",     # Cgroup filesystem reader
]
resolver = "2"

[workspace.dependencies]
serde = { version = "1.0", features = ["derive"] }
anyhow = "1.0"
```

```
my_project/
├── Cargo.toml          # Workspace root
├── app/                # Binary crate
│   ├── Cargo.toml
│   └── src/main.rs
├── common/             # Shared library
│   ├── Cargo.toml
│   └── src/lib.rs
└── model/              # Domain models
    ├── Cargo.toml
    └── src/lib.rs
```

**When NOT to use:**
- Small projects with fewer than 1000 lines of code
- Single-purpose CLI tools or libraries
