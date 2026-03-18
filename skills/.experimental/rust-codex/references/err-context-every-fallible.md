---
title: Use .context() on Every Fallible Operation
impact: CRITICAL
impactDescription: prevents opaque errors, saves 5-30min per debug session
tags: err, context, anyhow, error-handling
---

## Use .context() on Every Fallible Operation

Every use of the `?` operator on a `Result` must include a `.context()` call that describes the operation being attempted. Without context, errors propagate as generic messages like "No such file or directory" with no indication of which file or why it was being accessed.

**Incorrect (opaque error on failure):**

```rust
fn load_config(path: &Path) -> anyhow::Result<ConfigToml> {
    let content = std::fs::read_to_string(path)?;
    let config: ConfigToml = toml::from_str(&content)?;
    Ok(config)
}
```

**Correct (actionable error message):**

```rust
fn load_config(path: &Path) -> anyhow::Result<ConfigToml> {
    let content = std::fs::read_to_string(path)
        .context("failed to read config file")?;
    let config: ConfigToml = toml::from_str(&content)
        .context("failed to parse TOML config")?;
    Ok(config)
}
```
