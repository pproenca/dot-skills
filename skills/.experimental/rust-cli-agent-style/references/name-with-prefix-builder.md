---
title: Use with_ prefix for builder methods
impact: MEDIUM
impactDescription: Consistent builder API across the codebase
tags: name, builder, methods
---

# Use with_ prefix for builder methods

Builder methods that set a value should use the `with_` prefix.

## Why This Matters

- Consistent API pattern
- Clear distinction from getters
- Chainable method indication
- Self-documenting code

**Incorrect (avoid this pattern):**

```rust
impl ConfigBuilder {
    pub fn set_timeout(mut self, t: Duration) -> Self {
        self.timeout = t;
        self
    }

    pub fn timeout(mut self, t: Duration) -> Self {  // Confusing - is this getter or setter?
        self.timeout = t;
        self
    }

    pub fn add_host(mut self, h: String) -> Self {  // "add" implies collection append
        self.host = h;
        self
    }
}
```

**Correct (recommended):**

```rust
impl ConfigBuilder {
    pub fn with_timeout(mut self, timeout: Duration) -> Self {
        self.timeout = timeout;
        self
    }

    pub fn with_host(mut self, host: impl Into<String>) -> Self {
        self.host = host.into();
        self
    }

    pub fn with_tls(mut self, enabled: bool) -> Self {
        self.tls_enabled = enabled;
        self
    }

    pub fn with_retries(mut self, count: u32) -> Self {
        self.max_retries = count;
        self
    }
}

// Usage
let config = ConfigBuilder::new()
    .with_host("localhost")
    .with_timeout(Duration::from_secs(30))
    .with_tls(true)
    .build()?;
```

## Setter vs Builder

| Pattern | Use Case | Convention |
|---------|----------|------------|
| `with_*` | Builder (consumes self) | `fn with_x(mut self, x: T) -> Self` |
| `set_*` | Mutation (borrows self) | `fn set_x(&mut self, x: T)` |
| Getter | Read access | `fn x(&self) -> &T` |
