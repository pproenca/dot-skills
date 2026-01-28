---
title: Avoid expect() in library code
impact: CRITICAL
impactDescription: Library code should never panic - callers cannot recover from panics
tags: err, expect, panic, library
---

# Avoid expect() in library code

The codebase enforces `#![deny(clippy::expect_used)]` at the workspace level. Library code should return `Result` instead of panicking with `expect()`.

## Why This Matters

- Library consumers cannot catch panics easily
- Panics bypass error handling code paths
- `Result` types allow callers to decide how to handle errors
- Better composability with other error-returning functions

**Incorrect (avoid this pattern):**

```rust
// In library code
pub fn load_config(path: &Path) -> Config {
    let content = fs::read_to_string(path)
        .expect("config file must exist");
    toml::from_str(&content)
        .expect("config must be valid TOML")
}
```

**Correct (recommended):**

```rust
// Return Result instead
pub fn load_config(path: &Path) -> Result<Config, ConfigError> {
    let content = fs::read_to_string(path)
        .map_err(|e| ConfigError::ReadFailed { path: path.to_owned(), source: e })?;
    toml::from_str(&content)
        .map_err(ConfigError::ParseFailed)
}

// If expect is truly necessary (static data, etc.), use #[expect] with reason
#[expect(clippy::expect_used, reason = "static regex is always valid")
static PATTERN: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"^\d+$").expect("static regex")
});
```

## When expect() Might Be Acceptable

Only in truly infallible situations:
- Static/const data initialization
- After explicit validation
- In binary entry points (main)

Even then, prefer returning `Result` when possible.
