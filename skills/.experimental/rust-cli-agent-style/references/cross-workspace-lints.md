---
title: Define common lints in workspace Cargo.toml
impact: HIGH
impactDescription: Consistent lint configuration across all workspace crates
tags: cross, lints, workspace
---

# Define common lints in workspace Cargo.toml

Use `[workspace.lints.clippy]` to enforce consistent lint rules across all crates.

## Why This Matters

- Consistent code quality across workspace
- Single source of truth for lint config
- Easy to update rules
- Prevents lint drift between crates

**Incorrect (per-crate lints):**

```toml
# In core/Cargo.toml
[lints.clippy]
unwrap_used = "deny"

# In cli/Cargo.toml - inconsistent!
[lints.clippy]
unwrap_used = "warn"  # Different level
```

**Correct (workspace lints):**

```toml
# In workspace Cargo.toml
[workspace.lints.clippy]
unwrap_used = "deny"
expect_used = "deny"

# In core/Cargo.toml
[lints]
workspace = true
```

## Full Example

Workspace Cargo.toml:

```toml
[workspace.lints.rust]
unsafe_code = "deny"

[workspace.lints.clippy]
# Deny panicking operations
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"

# Deny common mistakes
print_stdout = "deny"
print_stderr = "deny"
dbg_macro = "deny"

# Code quality
needless_pass_by_value = "warn"
redundant_clone = "warn"
uninlined_format_args = "warn"

# Style preferences
module_name_repetitions = "allow"
```

## Crate-Level Inheritance

In each crate's Cargo.toml:

```toml
[package]
name = "codex-core"
version.workspace = true

[lints]
workspace = true
```

## Crate-Specific Overrides

When a crate needs different rules:

```toml
[package]
name = "codex-cli"

[lints]
workspace = true

[lints.clippy]
# CLI binary can print to stdout
print_stdout = "allow"
print_stderr = "allow"
```

## Test Code Exceptions

In clippy.toml:

```toml
allow-unwrap-in-tests = true
allow-expect-in-tests = true
```
