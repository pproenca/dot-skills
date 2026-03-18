---
title: Use anyhow for Application-Level Error Handling
impact: CRITICAL
impactDescription: reduces error boilerplate by 50-70% in application code
tags: errprop, anyhow, application, error-handling, context
---

## Use anyhow for Application-Level Error Handling

Use `anyhow::Result` in application code (binaries, CLI tools, integration tests) where callers do not need to match on specific error variants. Reserve typed errors for library boundaries where downstream consumers need structured matching.

**Incorrect (custom error type in a CLI with no variant matching):**

```rust
#[derive(Debug)]
enum AppError {
    Config(std::io::Error),
    Parse(toml::de::Error),
    Runtime(String),
}
// 30 lines of Display, From impls that nobody matches on
```

**Correct (anyhow with contextual messages):**

```rust
use anyhow::{Context, Result};

fn run_application(config_path: &Path) -> Result<()> {
    let config = load_config(config_path)
        .context("failed to load application config")?;
    let session = Session::new(&config)
        .context("failed to initialize session")?;
    session.run().await
        .context("session terminated unexpectedly")
}
```
