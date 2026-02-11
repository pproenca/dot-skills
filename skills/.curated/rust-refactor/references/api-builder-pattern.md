---
title: Use Builder Pattern for Complex Construction
impact: HIGH
impactDescription: enables optional parameters without function overloading
tags: api, builder, construction, optional, fluent
---

## Use Builder Pattern for Complex Construction

Use the builder pattern for types with many optional parameters. Rust lacks function overloading and default arguments, making builders essential.

**Incorrect (many parameters, hard to use):**

```rust
pub struct ServerConfig {
    host: String,
    port: u16,
    max_connections: usize,
    timeout_ms: u64,
    use_tls: bool,
    cert_path: Option<String>,
}

impl ServerConfig {
    pub fn new(
        host: String,
        port: u16,
        max_connections: usize,
        timeout_ms: u64,
        use_tls: bool,
        cert_path: Option<String>,
    ) -> Self {
        // Hard to remember parameter order
        ServerConfig { host, port, max_connections, timeout_ms, use_tls, cert_path }
    }
}
```

**Correct (builder with method chaining):**

```rust
#[derive(Default)]
pub struct ServerConfigBuilder {
    host: String,
    port: u16,
    max_connections: usize,
    timeout_ms: u64,
}

impl ServerConfigBuilder {
    pub fn new(host: impl Into<String>, port: u16) -> Self {
        Self { host: host.into(), port, max_connections: 100, timeout_ms: 30_000 }
    }

    pub fn max_connections(mut self, n: usize) -> Self {
        self.max_connections = n;
        self
    }

    pub fn timeout_ms(mut self, ms: u64) -> Self {
        self.timeout_ms = ms;
        self
    }

    pub fn build(self) -> ServerConfig {
        ServerConfig {
            host: self.host, port: self.port,
            max_connections: self.max_connections, timeout_ms: self.timeout_ms,
        }
    }
}

// Usage is clear and self-documenting
let config = ServerConfigBuilder::new("localhost", 8080)
    .max_connections(500)
    .timeout_ms(60_000)
    .build();
```

**Alternative:** Use `derive_builder` or `typed-builder` crates for automatic generation.

Reference: [Builder - Rust Design Patterns](https://rust-unofficial.github.io/patterns/patterns/creational/builder.html)
