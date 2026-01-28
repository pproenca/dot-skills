---
title: Use builder pattern for complex configuration
impact: MEDIUM
impactDescription: Builders make construction of complex types readable and flexible
tags: mod, builder, construction
---

# Use builder pattern for complex configuration

Implement the builder pattern with `Default` for types with many optional fields.

## Why This Matters

- Clear, readable construction
- Optional fields without Option<> overload
- Compile-time checked required fields
- Chainable API

**Incorrect (avoid this pattern):**

```rust
// Too many constructor parameters
let config = Config::new(
    "localhost",
    8080,
    true,
    Some(Duration::from_secs(30)),
    None,
    true,
    false,
);
```

**Correct (recommended):**

```rust
#[derive(Debug, Clone)
pub struct Config {
    host: String,
    port: u16,
    tls_enabled: bool,
    timeout: Duration,
    max_retries: u32,
}

#[derive(Debug, Clone, Default)
pub struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    tls_enabled: bool,
    timeout: Duration,
    max_retries: u32,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn with_host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    pub fn with_port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    pub fn with_tls(mut self, enabled: bool) -> Self {
        self.tls_enabled = enabled;
        self
    }

    pub fn with_timeout(mut self, timeout: Duration) -> Self {
        self.timeout = timeout;
        self
    }

    pub fn build(self) -> Result<Config, ConfigError> {
        Ok(Config {
            host: self.host.ok_or(ConfigError::MissingField("host"))?,
            port: self.port.unwrap_or(8080),
            tls_enabled: self.tls_enabled,
            timeout: self.timeout,
            max_retries: self.max_retries,
        })
    }
}

// Usage
let config = ConfigBuilder::new()
    .with_host("localhost")
    .with_port(3000)
    .with_tls(true)
    .with_timeout(Duration::from_secs(60))
    .build()?;
```

## Default Trait Integration

```rust
impl Default for ConfigBuilder {
    fn default() -> Self {
        Self {
            host: None,
            port: None,
            tls_enabled: false,
            timeout: Duration::from_secs(30),
            max_retries: 3,
        }
    }
}
```
