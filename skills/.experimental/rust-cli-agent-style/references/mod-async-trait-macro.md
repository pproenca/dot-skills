---
title: Use #[async_trait] for async trait methods
impact: HIGH
impactDescription: Enables async methods in traits which Rust doesn't natively support yet
tags: mod, async, traits
---

# Use #[async_trait] for async trait methods

Apply the `#[async_trait]` attribute when defining traits with async methods.

## Why This Matters

- Rust doesn't have native async trait support yet
- `async_trait` macro provides the workaround
- Required for async trait methods to compile
- Widely used in async Rust ecosystem

**Incorrect (avoid this pattern):**

```rust
// Won't compile - async fn not allowed in traits (without RPITIT)
pub trait Handler {
    async fn handle(&self, request: Request) -> Response;
}
```

**Correct (recommended):**

```rust
use async_trait::async_trait;

#[async_trait
pub trait Handler {
    async fn handle(&self, request: Request) -> Response;
}

#[async_trait
impl Handler for MyHandler {
    async fn handle(&self, request: Request) -> Response {
        // Implementation
    }
}
```

## With Send Bound (Default)

The `#[async_trait]` macro adds `Send` bound by default:

```rust
#[async_trait
pub trait Transport: Send + Sync {
    async fn send(&self, data: &[u8]) -> io::Result<()>;
    async fn recv(&self) -> io::Result<Vec<u8>>;
}
```

## Without Send Bound

For single-threaded contexts:

```rust
#[async_trait(?Send)
pub trait LocalHandler {
    async fn handle(&self) -> Result<()>;
}
```

## Note on Rust 1.75+

Rust 1.75+ supports async fn in traits via RPITIT for some cases. However, `#[async_trait]` is still commonly used for:
- Object safety (`dyn Trait`)
- Complex trait bounds
- Compatibility with older code
