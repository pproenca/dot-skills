---
title: Use context() and with_context() for Error Messages
impact: MEDIUM
impactDescription: Context methods add information without losing the original error chain
tags: err, anyhow, context, error-chain
---

## Use context() and with_context() for Error Messages

Use `.context()` for static messages and `.with_context()` with a closure for dynamic messages. Both preserve the error chain.

**Incorrect (problematic pattern):**

```rust
// Losing context
fn process_file(path: &Path) -> Result<Data> {
    let file = File::open(path)?;  // "No such file" - which file?
    let data = parse(file)?;       // "Parse error" - parsing what?
    Ok(data)
}

// Eager evaluation of format string
fn process_file(path: &Path) -> Result<Data> {
    let file = File::open(path)
        .context(format!("Failed to open {}", path.display()))?;  // Always allocates
    Ok(data)
}
```

**Correct (recommended pattern):**

```rust
use anyhow::{Context, Result};

fn process_file(path: &Path) -> Result<Data> {
    // .context() for static strings - no allocation if Ok
    let file = File::open(path)
        .context("Failed to open file")?;

    // .with_context() for dynamic messages - lazy evaluation
    let data = parse(&file)
        .with_context(|| format!("Failed to parse {}", path.display()))?;

    Ok(data)
}

// Chaining multiple contexts builds error chain
fn load_config() -> Result<Config> {
    let path = get_config_path()
        .context("Failed to determine config path")?;

    let content = std::fs::read_to_string(&path)
        .with_context(|| format!("Failed to read {}", path.display()))?;

    let config: Config = toml::from_str(&content)
        .with_context(|| format!("Failed to parse config from {}", path.display()))?;

    validate(&config)
        .context("Config validation failed")?;

    Ok(config)
}

// Error output shows full chain:
// Error: Config validation failed
//
// Caused by:
//     0: Failed to parse config from /etc/app/config.toml
//     1: missing field 'name'
```

**When NOT to use:**
- Library code (use thiserror instead)
- When the error is already descriptive enough
