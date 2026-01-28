---
title: Use flat workspace structure with utils subdirectory
impact: HIGH
impactDescription: Consistent workspace layout enables easy navigation and discovery
tags: org, workspace, structure
---

# Use flat workspace structure with utils subdirectory

Place all crates at workspace root level. Group small utility crates under a `utils/` subdirectory.

## Why This Matters

- Easy to find and navigate crates
- Clear separation between main and utility crates
- Consistent with Rust ecosystem conventions
- Scales well as workspace grows

**Incorrect (deeply nested or disorganized):**

```text
workspace/
├── Cargo.toml
├── crates/
│   ├── main/
│   │   └── core/      # Too deeply nested
│   └── helpers/
│       └── utils/
│           └── git/   # Hard to navigate
└── lib/
    └── common/        # Inconsistent location
```

**Correct (flat with utils subdirectory):**

```text
workspace/
├── Cargo.toml          # Workspace manifest
├── Cargo.lock
├── core/               # Main crates at root
├── cli/
├── tui/
├── protocol/
├── app-server/
├── backend-client/
├── utils/              # Small utilities grouped
│   ├── git/
│   ├── cache/
│   ├── pty/
│   └── config/
└── tests/
    └── common/         # Shared test utilities
```

## Workspace Cargo.toml

```toml
[workspace]
resolver = "2"
members = [
    "core",
    "cli",
    "tui",
    "protocol",
    "app-server",
    "backend-client",
    "utils/*",
    "tests/common",
]

[workspace.package]
version = "0.1.0"
edition = "2024"
license = "MIT"

[workspace.dependencies]
# Centralized dependencies
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
```

## When to Use utils/

Move crates to `utils/` when:
- Single-purpose utility functionality
- Unlikely to be used externally
- Small codebase (few files)
- No complex dependencies

Keep at root when:
- Core application component
- Significant size/complexity
- External API surface
