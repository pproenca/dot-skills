---
title: Use anyhow for Application Error Handling
impact: HIGH
impactDescription: reduces error handling boilerplate by 40%
tags: err, anyhow, application, context, error-propagation
---

## Use anyhow for Application Error Handling

Use `anyhow` at the application level for ergonomic error handling with context. It wraps any error type and adds backtraces.

**Incorrect (verbose error handling in applications):**

```rust
fn load_user_config() -> Result<Config, Box<dyn std::error::Error>> {
    let path = get_config_path()?;
    let content = std::fs::read_to_string(&path)
        .map_err(|e| format!("failed to read {}: {}", path.display(), e))?;
    let config: Config = toml::from_str(&content)
        .map_err(|e| format!("failed to parse config: {}", e))?;
    Ok(config)
}
```

**Correct (anyhow with context):**

```rust
use anyhow::{Context, Result};

fn load_user_config() -> Result<Config> {
    let path = get_config_path()?;
    let content = std::fs::read_to_string(&path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    let config: Config = toml::from_str(&content)
        .context("failed to parse config")?;
    Ok(config)
}
```

**Benefits:**
- `anyhow::Result<T>` is an alias for `Result<T, anyhow::Error>`
- `.context()` adds human-readable context to errors
- Automatic backtrace capture (with RUST_BACKTRACE=1)
- Works with any error type implementing `std::error::Error`

**Library vs Application:**

| Use Case | Crate | Why |
|----------|-------|-----|
| Library | `thiserror` | Callers need typed errors to handle variants |
| Application | `anyhow` | Errors are logged/displayed, not matched |

Reference: [anyhow crate](https://docs.rs/anyhow)
