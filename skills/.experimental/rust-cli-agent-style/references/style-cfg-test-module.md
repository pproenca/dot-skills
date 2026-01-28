---
title: Place unit tests in #[cfg(test)] mod tests
impact: HIGH
impactDescription: Standard Rust test organization pattern
tags: style, testing, modules
---

# Place unit tests in #[cfg(test)] mod tests

Unit tests go in a `tests` submodule at the bottom of the file.

## Why This Matters

- Standard Rust convention
- Tests compiled only for test builds
- Tests have access to private items
- Clear separation of concerns

**Incorrect (tests in separate file or mixed with code):**

```rust
// src/config.rs
pub struct Config {
    timeout: Duration,
}

// Tests scattered or in wrong location
#[test]  // Wrong: not in cfg(test) module
fn test_config() {
    let config = Config::new();
}
```

**Correct (tests in cfg(test) module):**

```rust
// src/config.rs
use std::path::Path;

pub struct Config {
    timeout: Duration,
}

impl Config {
    pub fn new() -> Self {
        Self {
            timeout: Duration::from_secs(30),
        }
    }

    fn validate(&self) -> bool {
        self.timeout.as_secs() > 0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_config_has_default_timeout() {
        let config = Config::new();
        assert_eq!(config.timeout, Duration::from_secs(30));
    }

    #[test]
    fn test_validate_accepts_valid_config() {
        let config = Config::new();
        assert!(config.validate());  // Can access private method
    }
}
```

## Async Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_async_operation() {
        let result = async_function().await;
        assert!(result.is_ok());
    }
}
```

## Test Helpers

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // Test-only helper
    fn create_test_config() -> Config {
        Config {
            timeout: Duration::from_millis(100),
        }
    }

    #[test]
    fn test_something() {
        let config = create_test_config();
        // ...
    }
}
```

## Integration vs Unit Tests

| Type | Location | Access |
|------|----------|--------|
| Unit tests | `src/*.rs` in `mod tests` | Private items |
| Integration tests | `tests/*.rs` | Public API only |
