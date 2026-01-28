---
title: Use Options suffix for configuration bundles
impact: MEDIUM
impactDescription: Clear naming for optional configuration structures
tags: name, configuration, types
---

# Use Options suffix for configuration bundles

Types that bundle optional configuration should use the `Options` suffix.

## Why This Matters

- Distinguishes from required config
- Clear that fields are optional
- Consistent pattern for overrides
- Self-documenting API

**Incorrect (avoid this pattern):**

```rust
// Unclear these are optional configurations
pub struct ServerConfig { }      // Required or optional?
pub struct ClientSettings { }    // All required?
pub struct RequestParams { }     // Configuration or data?
```

**Correct (recommended):**

```rust
/// Optional server configuration. All fields have defaults.
#[derive(Debug, Clone, Default)
pub struct ServerOptions {
    pub port: Option<u16>,
    pub host: Option<String>,
    pub timeout: Option<Duration>,
    pub max_connections: Option<usize>,
}

/// Optional client configuration.
#[derive(Debug, Clone, Default)
pub struct ClientOptions {
    pub retry_count: Option<u32>,
    pub user_agent: Option<String>,
    pub proxy: Option<String>,
}

// Usage - all optional
fn create_server(options: ServerOptions) -> Server {
    let port = options.port.unwrap_or(8080);
    let host = options.host.unwrap_or_else(|| "localhost".into());
    // ...
}

// Or with builder
let server = Server::builder()
    .options(ServerOptions {
        port: Some(3000),
        ..Default::default()
    })
    .build();
```

## Related Patterns

| Suffix | Use Case |
|--------|----------|
| `Options` | Optional configuration bundle |
| `Config` | Required configuration |
| `Settings` | User preferences |
| `Params` | Function parameters bundle |
