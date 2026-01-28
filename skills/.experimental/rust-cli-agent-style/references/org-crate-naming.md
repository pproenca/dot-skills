---
title: Use kebab-case for crate directories with project prefix
impact: HIGH
impactDescription: Consistent naming enables easy identification of internal crates
tags: org, naming, crates
---

# Use kebab-case for crate directories with project prefix

Directory names use kebab-case. Package names in Cargo.toml use a project prefix for internal crates.

## Why This Matters

- Distinguishes internal crates from external dependencies
- Prevents name collisions with crates.io packages
- Easy to identify project crates in Cargo.lock
- Consistent with Rust conventions

**Incorrect (avoid this pattern):**

```
my_crate/           # Wrong: underscore
myClient/           # Wrong: camelCase
```

```toml
[package
name = "backend-client"  # Wrong: no project prefix
```

**Correct (recommended):**

Directory structure:
```
backend-client/     # kebab-case directory
app-server/
mcp-types/
```

Cargo.toml:
```toml
# In backend-client/Cargo.toml
[package
name = "codex-backend-client"  # Project prefix: codex-

# In app-server/Cargo.toml
[package
name = "codex-app-server"
```

## Dependency References

```toml
# In another crate's Cargo.toml
[dependencies
codex-backend-client = { path = "../backend-client" }
codex-protocol = { path = "../protocol" }
```

## Internal Crate Imports

```rust
use codex_backend_client::Client;
use codex_protocol::Message;
```

Note: Package names with hyphens become underscores in `use` statements.
