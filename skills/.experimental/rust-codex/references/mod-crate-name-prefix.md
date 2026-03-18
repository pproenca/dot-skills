---
title: Prefix All Crate Names with codex-
impact: HIGH
impactDescription: maintains consistent naming across the workspace
tags: mod, crate-naming, workspace, conventions
---

## Prefix All Crate Names with codex-

Every crate in the workspace uses the `codex-` prefix. For example, the `core` folder contains the `codex-core` crate, the `tui` folder contains the `codex-tui` crate, and so on. This convention prevents name collisions with external crates and makes workspace members immediately identifiable.

**Incorrect (missing crate prefix):**

```toml
# codex-rs/my-feature/Cargo.toml
[package]
name = "my-feature"
version = "0.1.0"

[dependencies]
core = { path = "../core" }
```

**Correct (codex- prefix on crate name):**

```toml
# codex-rs/my-feature/Cargo.toml
[package]
name = "codex-my-feature"
version = "0.1.0"

[dependencies]
codex-core = { path = "../core" }
```

Note: In Rust source code, hyphens become underscores: `use codex_core::Config;`.
