---
title: Use anyhow::Result for application entry points
impact: HIGH
impactDescription: Simplifies error handling in application code while preserving error context
tags: err, anyhow, application
---

# Use anyhow::Result for application entry points

Use `anyhow::Result` in `main()` and top-level application code. Reserve `thiserror` for library/domain errors.

## Why This Matters

- `anyhow` provides easy error context chaining
- Automatic error source tracking
- Good for application code where you just want to report errors
- Separates "what went wrong" from "how to handle it"

## Pattern

```
Library code (thiserror) → Application code (anyhow) → User
```

**Incorrect (avoid this pattern):**

```rust
// Using thiserror for main() - overly complex
#[derive(Debug, Error)
enum MainError {
    #[error(transparent)
    Config(#[from] ConfigError),
    #[error(transparent)
    Server(#[from] ServerError),
    // ... many more variants
}

fn main() -> Result<(), MainError> { ... }
```

**Correct (recommended):**

```rust
use anyhow::Result;
use anyhow::Context;

fn main() -> Result<()> {
    let config = load_config()
        .context("failed to load configuration")?;

    let server = Server::new(&config)
        .context("failed to initialize server")?;

    server.run()
        .context("server error")?;

    Ok(())
}

// Or with tokio
#[tokio::main
async fn main() -> Result<()> {
    run_app().await
}

async fn run_app() -> Result<()> {
    // Application logic with anyhow for easy error chaining
}
```

## Library vs Application

| Context | Error Type | Example |
|---------|-----------|---------|
| Library crate | `thiserror` | `ConfigError`, `ParseError` |
| Application entry | `anyhow::Result` | `main()`, `run_app()` |
| CLI handlers | `anyhow::Result` | Command implementations |
