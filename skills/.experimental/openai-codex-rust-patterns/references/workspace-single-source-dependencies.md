---
title: Declare every dependency version once in workspace.dependencies
impact: MEDIUM
impactDescription: prevents silent version skew and duplicate crate compilations
tags: workspace, cargo, dependency-management
---

## Declare every dependency version once in workspace.dependencies

When leaf crates declare `tokio = "1.28"` while the root has `tokio = "1"`, you get silent version skew and two compiled copies of the same crate. Codex's root `Cargo.toml` has ~160 external deps declared exactly once with versions, plus every internal crate pre-declared as `path = ...`. Leaf crates inherit with `{ workspace = true, features = [...] }`, adding *only* the feature set they need. Bumping a dep is a one-line diff to the root.

**Incorrect (leaf crates pin their own versions):**

```toml
# core/Cargo.toml
[dependencies]
tokio = { version = "1.28", features = ["rt-multi-thread"] }
reqwest = { version = "0.11", features = ["json"] }

# tui/Cargo.toml
[dependencies]
tokio = "1" # drift: core has 1.28, tui has 1.x → two compiled copies
```

**Correct (versions in workspace root, leaves only add features):**

```toml
# Cargo.toml (workspace root) — declared ONCE
[workspace.dependencies]
tokio = "1"
reqwest = "0.12"
rmcp = { version = "0.15.0", default-features = false }

# Internal crates pre-registered by path
codex-protocol = { path = "protocol" }
codex-utils-elapsed = { path = "utils/elapsed" }

# core/Cargo.toml — leaves pick features, never versions
[dependencies]
reqwest = { workspace = true, features = ["json", "stream"] }
rmcp = {
    workspace = true,
    default-features = false,
    features = ["base64", "macros", "schemars", "server"],
}
tokio = {
    workspace = true,
    features = ["io-std", "macros", "process", "rt-multi-thread", "signal"],
}
```

The root pins *bare* versions — no default features stripped, no feature list. Every feature list lives with the crate that needs it, so grepping `features = ["foo"]` across the workspace gives an instant "who uses foo" index.

Reference: `codex-rs/Cargo.toml:195`, `codex-rs/core/Cargo.toml:89`.
