---
title: Use Result Instead of panic! for Recoverable Errors
impact: HIGH
impactDescription: enables graceful error handling, prevents crashes
tags: err, result, panic, recoverable, error-handling
---

## Use Result Instead of panic! for Recoverable Errors

Return `Result<T, E>` for operations that can fail recoverably. Reserve `panic!` for unrecoverable states or programming errors.

**Incorrect (panics on expected failures):**

```rust
fn parse_config(content: &str) -> Config {
    let lines: Vec<&str> = content.lines().collect();
    if lines.is_empty() {
        panic!("Config file is empty");  // Crashes entire program
    }

    let name = lines[0].strip_prefix("name=")
        .expect("Missing name field");  // Crashes on missing field

    Config { name: name.to_string() }
}
```

**Correct (returns Result for recoverable errors):**

```rust
#[derive(Debug)]
enum ConfigError {
    EmptyFile,
    MissingField(&'static str),
    InvalidFormat(String),
}

fn parse_config(content: &str) -> Result<Config, ConfigError> {
    let lines: Vec<&str> = content.lines().collect();
    if lines.is_empty() {
        return Err(ConfigError::EmptyFile);
    }

    let name = lines[0]
        .strip_prefix("name=")
        .ok_or(ConfigError::MissingField("name"))?;

    Ok(Config { name: name.to_string() })
}
```

**When panic! is appropriate:**
- Programming errors that indicate bugs (index out of bounds when logic guarantees validity)
- Unrecoverable states (corrupted internal invariants)
- Tests and examples

Reference: [Error Handling - The Rust Book](https://doc.rust-lang.org/book/ch09-00-error-handling.html)
