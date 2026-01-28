---
title: Order impl blocks consistently
impact: LOW
impactDescription: Consistent ordering makes code navigation predictable
tags: mod, impl, ordering
---

# Order impl blocks consistently

Order impl blocks: inherent impl first, then trait impls (std traits first), then From/Into impls.

## Why This Matters

- Predictable code structure
- Easy to find specific implementations
- Consistent across codebase
- Follows community conventions

**Incorrect (random ordering):**

```rust
impl From<String> for Config {
    fn from(host: String) -> Self { Self::new(host) }
}

impl Config {
    pub fn new(host: impl Into<String>) -> Self { /* ... */ }
}

impl Default for Config {
    fn default() -> Self { Self::new("localhost") }
}
```

**Correct (consistent ordering):**

```rust
pub struct Config {
    pub timeout: Duration,
    pub host: String,
}

// 1. Inherent impl first
impl Config {
    pub fn new(host: impl Into<String>) -> Self {
        Self {
            timeout: Duration::from_secs(30),
            host: host.into(),
        }
    }

    pub fn with_timeout(mut self, timeout: Duration) -> Self {
        self.timeout = timeout;
        self
    }
}

// 2. Standard library traits
impl Default for Config {
    fn default() -> Self {
        Self::new("localhost")
    }
}

impl fmt::Display for Config {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}:{}", self.host, self.timeout.as_secs())
    }
}

// 3. From/Into conversions
impl From<String> for Config {
    fn from(host: String) -> Self {
        Self::new(host)
    }
}

// 4. Crate traits
impl crate::Validate for Config {
    fn validate(&self) -> Result<(), ValidationError> {
        // ...
    }
}
```
