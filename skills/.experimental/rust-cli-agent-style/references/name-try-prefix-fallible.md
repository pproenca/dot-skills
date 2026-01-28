---
title: Use try_ prefix for fallible constructors
impact: HIGH
impactDescription: Clear indication that construction can fail
tags: name, constructors, error-handling
---

# Use try_ prefix for fallible constructors

Constructors that can fail should use the `try_` prefix and return `Result`.

## Why This Matters

- Clear API contract
- Follows Rust convention (`try_from`, `try_into`)
- Distinguishes from infallible `new()`
- Compile-time enforced error handling

**Incorrect (avoid this pattern):**

```rust
impl Config {
    // Unclear - does this panic or return Result?
    pub fn from_file(path: &Path) -> Result<Self, ConfigError> { }
    pub fn from_env() -> Result<Self, ConfigError> { }
    pub fn from_str(s: &str) -> Result<Self, ConfigError> { }
}
```

**Correct (recommended):**

```rust
impl Config {
    /// Creates a config with defaults. Cannot fail.
    pub fn new() -> Self {
        Self::default()
    }

    /// Tries to load config from a file.
    pub fn try_from_file(path: &Path) -> Result<Self, ConfigError> {
        let content = fs::read_to_string(path)?;
        Self::try_from_str(&content)
    }

    /// Tries to load config from environment variables.
    pub fn try_from_env() -> Result<Self, ConfigError> {
        // ...
    }

    /// Tries to parse config from a string.
    pub fn try_from_str(s: &str) -> Result<Self, ConfigError> {
        toml::from_str(s).map_err(ConfigError::Parse)
    }
}
```

## Standard Library Pattern

Follows the standard library convention:

```rust
// std::convert
trait TryFrom<T> {
    type Error;
    fn try_from(value: T) -> Result<Self, Self::Error>;
}

// Usage
let num: u8 = u8::try_from(256i32)?;  // Returns Err
```

## Related Naming

| Infallible | Fallible |
|-----------|----------|
| `new()` | `try_new()` |
| `from_*()` | `try_from_*()` |
| `with_*()` | `try_with_*()` |
| `parse()` | Returns Result (already fallible) |
