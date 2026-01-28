---
title: Centralize dependency versions in workspace
impact: HIGH
impactDescription: Consistent dependency versions prevent version conflicts
tags: cross, dependencies, workspace
---

# Centralize dependency versions in workspace

Define all dependency versions in `[workspace.dependencies]` section.

## Why This Matters

- Single version per dependency
- No version conflicts between crates
- Easy to update dependencies
- Clear dependency audit

**Incorrect (scattered versions):**

```toml
# In core/Cargo.toml
[dependencies]
tokio = "1.35"
serde = "1.0.193"

# In cli/Cargo.toml - different versions!
[dependencies]
tokio = "1.34"
serde = "1.0.190"
```

**Correct (centralized versions):**

```toml
# In workspace Cargo.toml
[workspace.dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }

# In core/Cargo.toml
[dependencies]
tokio.workspace = true
serde.workspace = true
```

## Full Example

Workspace Cargo.toml:

```toml
[workspace]
resolver = "2"
members = ["core", "cli", "tui", "protocol"]

[workspace.package]
version = "0.1.0"
edition = "2024"
license = "MIT"

[workspace.dependencies]
# Async runtime
tokio = { version = "1", features = ["full"] }
async-trait = "0.1"

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Error handling
thiserror = "2"
anyhow = "1"

# Internal crates
codex-core = { path = "core" }
codex-protocol = { path = "protocol" }
```

Crate Cargo.toml:

```toml
[package]
name = "codex-core"
version.workspace = true
edition.workspace = true

[dependencies]
tokio.workspace = true
serde.workspace = true
thiserror.workspace = true

# With additional features
reqwest = { workspace = true, features = ["cookies"] }

[dev-dependencies]
tempfile = "3"  # Only used in this crate
```

## Benefits

1. **Version consistency**: All crates use the same version
2. **Single update point**: Update once, applies everywhere
3. **Feature consistency**: Default features defined centrally
4. **Clear overview**: All dependencies visible in one place
