---
title: Add context to Every Fallible Operation
impact: CRITICAL
impactDescription: saves 5-30min per debug session with actionable error messages
tags: errprop, context, anyhow, diagnostics, debugging
---

## Add context to Every Fallible Operation

Attach `.context()` or `.with_context()` to every `?` propagation. Without context, errors surface as generic messages like "No such file or directory" with no indication of which operation failed or why.

**Incorrect (opaque error, no operation context):**

```rust
fn read_permissions(home: &Path) -> anyhow::Result<PermissionsToml> {
    let path = home.join("permissions.toml");
    let content = std::fs::read_to_string(&path)?;
    let perms: PermissionsToml = toml::from_str(&content)?;
    Ok(perms)
}
```

**Correct (each step annotated with what was attempted):**

```rust
use anyhow::Context;

fn read_permissions(home: &Path) -> anyhow::Result<PermissionsToml> {
    let path = home.join("permissions.toml");
    let content = std::fs::read_to_string(&path)
        .context("failed to read permissions file")?;
    let perms: PermissionsToml = toml::from_str(&content)
        .context("failed to parse permissions TOML")?;
    Ok(perms)
}
```
