---
title: Avoid unwrap() in Production Code
impact: CRITICAL
impactDescription: prevents runtime panics in production (clippy::unwrap_used is denied)
tags: err, unwrap, panic, clippy
---

## Avoid unwrap() in Production Code

The codebase denies `clippy::unwrap_used` in production modules. Every `.unwrap()` is a potential runtime panic. Use `.context()` with `?` to convert `Option` and `Result` into descriptive errors, or use `unwrap_or_else` / `unwrap_or_default` when a fallback is appropriate.

**Incorrect (runtime panic on missing key):**

```rust
fn get_api_base(config: &ConfigToml) -> String {
    let base_url = config.api_base_url.as_ref().unwrap();
    let token = std::env::var("OPENAI_API_KEY").unwrap();
    format!("{base_url}/v1/responses?token={token}")
}
```

**Correct (descriptive error propagation):**

```rust
fn get_api_base(config: &ConfigToml) -> anyhow::Result<String> {
    let base_url = config.api_base_url.as_ref()
        .context("missing api_base_url in config")?;
    let token = std::env::var("OPENAI_API_KEY")
        .context("OPENAI_API_KEY environment variable not set")?;
    Ok(format!("{base_url}/v1/responses?token={token}"))
}
```
