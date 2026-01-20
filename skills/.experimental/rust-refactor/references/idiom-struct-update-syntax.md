---
title: Use Struct Update Syntax for Partial Overrides
impact: MEDIUM
impactDescription: reduces boilerplate when creating variants of structs
tags: idiom, struct, update-syntax, default, copy
---

## Use Struct Update Syntax for Partial Overrides

Use `..` struct update syntax to create variants of a struct with only some fields changed. This reduces boilerplate and makes changes explicit.

**Incorrect (repeating all fields):**

```rust
#[derive(Clone)]
struct ServerConfig {
    host: String,
    port: u16,
    max_connections: usize,
    timeout_ms: u64,
    use_tls: bool,
}

fn create_test_config(base: &ServerConfig) -> ServerConfig {
    ServerConfig {
        host: "localhost".to_string(),
        port: 8080,
        max_connections: base.max_connections,  // Copying unchanged
        timeout_ms: base.timeout_ms,            // Copying unchanged
        use_tls: false,                         // Override
    }
}
```

**Correct (struct update syntax):**

```rust
fn create_test_config(base: &ServerConfig) -> ServerConfig {
    ServerConfig {
        host: "localhost".to_string(),
        port: 8080,
        use_tls: false,
        ..base.clone()  // Fill remaining fields from base
    }
}

// Works great with Default
fn custom_config() -> ServerConfig {
    ServerConfig {
        port: 9000,
        use_tls: true,
        ..Default::default()  // Fill rest with defaults
    }
}
```

**Note:** For `Copy` types, use `*base` instead of `base.clone()`:

```rust
#[derive(Copy, Clone)]
struct Point { x: i32, y: i32, z: i32 }

fn with_new_x(p: Point, x: i32) -> Point {
    Point { x, ..p }  // No clone needed for Copy types
}
```

Reference: [Struct Update Syntax - Rust Book](https://doc.rust-lang.org/book/ch05-01-defining-structs.html#creating-instances-from-other-instances-with-struct-update-syntax)
