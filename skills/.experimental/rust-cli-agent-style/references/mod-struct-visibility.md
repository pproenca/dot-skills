---
title: Default to private fields with public constructor
impact: MEDIUM
impactDescription: Encapsulation enables future changes without breaking API
tags: mod, visibility, encapsulation
---

# Default to private fields with public constructor

Keep struct fields private by default; provide `new()` or builder for construction.

## Why This Matters

- Internal representation can change
- Invariants can be enforced
- Validation happens at construction
- Clear API boundary

**Incorrect (avoid this pattern):**

```rust
// Public fields expose implementation
pub struct Config {
    pub host: String,
    pub port: u16,
    pub timeout_ms: u64,  // Implementation detail exposed
}

// Consumers can create invalid state
let config = Config {
    host: String::new(),  // Empty host - invalid!
    port: 0,              // Port 0 - invalid!
    timeout_ms: 0,
};
```

**Correct (recommended):**

```rust
pub struct Config {
    host: String,
    port: u16,
    timeout: Duration,
}

impl Config {
    /// Creates a new configuration.
    ///
    /// # Errors
    /// Returns error if host is empty or port is 0.
    pub fn new(host: impl Into<String>, port: u16) -> Result<Self, ConfigError> {
        let host = host.into();
        if host.is_empty() {
            return Err(ConfigError::EmptyHost);
        }
        if port == 0 {
            return Err(ConfigError::InvalidPort);
        }
        Ok(Self {
            host,
            port,
            timeout: Duration::from_secs(30),
        })
    }

    // Getters for read access
    pub fn host(&self) -> &str {
        &self.host
    }

    pub fn port(&self) -> u16 {
        self.port
    }

    pub fn timeout(&self) -> Duration {
        self.timeout
    }

    // Builder-style setters that validate
    pub fn with_timeout(mut self, timeout: Duration) -> Self {
        self.timeout = timeout;
        self
    }
}
```

## When Public Fields Are OK

- Simple data transfer objects (DTOs)
- Builder intermediate state
- Test-only types
- Tuple structs: `pub struct Id(pub u64);`
