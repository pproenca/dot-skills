---
title: Define crate-specific Result type alias
impact: MEDIUM
impactDescription: Reduces boilerplate and makes error types explicit
tags: name, result, types, alias
---

# Define crate-specific Result type alias

Define `type Result<T> = std::result::Result<T, CrateError>` for convenience.

## Why This Matters

- Reduces repetitive typing
- Clear what error type the crate uses
- Consistent signatures
- Easy to change error type later

**Incorrect (avoid this pattern):**

```rust
// Repetitive and verbose
pub fn load_config() -> std::result::Result<Config, ConfigError> { }
pub fn parse_command() -> std::result::Result<Command, ConfigError> { }
pub fn validate() -> std::result::Result<(), ConfigError> { }
```

**Correct (recommended):**

```rust
// In lib.rs or errors.rs
pub type Result<T> = std::result::Result<T, Error>;

// Or for module-specific errors
pub mod config {
    pub type Result<T> = std::result::Result<T, ConfigError>;
}
```

Usage:

```rust
use crate::Result;

pub fn load_config() -> Result<Config> { }
pub fn parse_command() -> Result<Command> { }
pub fn validate() -> Result<()> { }
```

## Multiple Error Types

When a crate has multiple error types:

```rust
// Crate-level alias
pub type Result<T> = std::result::Result<T, Error>;

// Module-specific aliases
pub mod io {
    pub type Result<T> = std::result::Result<T, IoError>;
}

pub mod parse {
    pub type Result<T> = std::result::Result<T, ParseError>;
}
```

## Naming the Alias

```rust
// Standard pattern
pub type Result<T> = std::result::Result<T, Error>;

// Or if "Error" name is taken
pub type CrateResult<T> = std::result::Result<T, CrateError>;
```
