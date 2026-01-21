---
title: Define Module-Local Result Type Alias
impact: LOW
impactDescription: Result aliases reduce verbosity and make error types consistent
tags: err, result, alias, type
---

## Define Module-Local Result Type Alias

Each module with custom errors should define a local `Result` type alias. This reduces verbosity and ensures consistent error handling.

**Incorrect (problematic pattern):**

```rust
// Verbose - repeating Error type everywhere
pub fn read_config() -> std::result::Result<Config, crate::Error> { ... }
pub fn write_config(c: &Config) -> std::result::Result<(), crate::Error> { ... }
pub fn validate(c: &Config) -> std::result::Result<bool, crate::Error> { ... }

// Or using different error types inconsistently
pub fn read_config() -> Result<Config, std::io::Error> { ... }
pub fn validate(c: &Config) -> Result<bool, ValidationError> { ... }
```

**Correct (recommended pattern):**

```rust
// Define once at module level
pub type Result<T> = std::result::Result<T, Error>;

// Or for libraries with multiple error types
pub type Result<T, E = Error> = std::result::Result<T, E>;

// Clean function signatures
pub fn read_config() -> Result<Config> { ... }
pub fn write_config(c: &Config) -> Result<()> { ... }
pub fn validate(c: &Config) -> Result<bool> { ... }

// Full module example
mod config {
    use thiserror::Error;

    #[derive(Debug, Error)]
    pub enum Error {
        #[error("IO error: {0}")]
        Io(#[from] std::io::Error),
        #[error("Invalid config: {0}")]
        Invalid(String),
    }

    pub type Result<T> = std::result::Result<T, Error>;

    pub fn load(path: &Path) -> Result<Config> {
        let content = std::fs::read_to_string(path)?;  // ? works with From
        parse(&content)
    }
}
```

**When NOT to use:**
- When the module only uses standard library Result
- In very small modules where the alias adds no clarity
