---
title: Register shared test helpers as workspace member crates
impact: MEDIUM
impactDescription: enables cross-crate test helper reuse without path-attribute hacks
tags: workspace, testing, cargo, dev-dependencies
---

## Register shared test helpers as workspace member crates

When integration tests across multiple crates share fixture code, the usual workaround is `#[path = "../../other_crate/tests/common/mod.rs"] mod common;` — fragile, confusing, and it recompiles the helpers for every test binary. Codex promotes each crate's test helpers to a first-class workspace member *without* moving them out of the crate that owns them. `core_test_support`, `app_test_support`, and `mcp_test_support` live at paths like `core/tests/common/Cargo.toml` — physically inside `core/tests/`, but registered in the root `[workspace.dependencies]` by path.

**Incorrect (path-attribute shims per test file):**

```rust
// In every test file across five crates
#[path = "../../other_crate/tests/common/mod.rs"]
mod common;
use common::setup_test_codex;
```

**Correct (test-support as a normal workspace crate):**

```toml
# Cargo.toml (root)
[workspace.dependencies]
# Internal — test-only crates live inside the tests/ directory
# of the crate they support, but registered here as workspace deps.
app_test_support = { path = "app-server/tests/common" }
core_test_support = { path = "core/tests/common" }
mcp_test_support = { path = "mcp-server/tests/common" }
```

```toml
# core/tests/common/Cargo.toml
[package]
name = "core_test_support"
version.workspace = true
edition.workspace = true
license.workspace = true

[lib]
path = "lib.rs"

[lints]
workspace = true
```

```toml
# core/Cargo.toml — consumer
[dev-dependencies]
core_test_support = { workspace = true }
```

The test-support crate uses snake_case (`core_test_support`) to signal it's internal; the `[lib] path = "lib.rs"` pulls the library root out of a `src/` subdirectory; it is NOT a member of `[workspace] members` but *is* registered in `[workspace.dependencies]`. `app_test_support` itself depends on `core_test_support`, proving these test crates compose into a helper pyramid just like production crates.

Reference: `codex-rs/Cargo.toml:105`, `codex-rs/core/tests/common/Cargo.toml:1`.
