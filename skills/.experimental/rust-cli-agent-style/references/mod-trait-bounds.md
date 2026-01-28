---
title: Include Send + Sync + 'static for concurrent traits
impact: HIGH
impactDescription: Proper bounds enable traits to work in async and multithreaded contexts
tags: mod, traits, concurrency
---

# Include Send + Sync + 'static for concurrent traits

Traits used in async/concurrent contexts should require `Send + Sync + 'static` bounds.

## Why This Matters

- Tokio requires `Send` for spawned tasks
- `Sync` enables sharing references across threads
- `'static` required for spawned futures
- Without these, trait objects won't work in async code

**Incorrect (avoid this pattern):**

```rust
// Missing bounds - won't work with tokio::spawn
pub trait Handler {
    fn handle(&self, req: Request) -> Response;
}

async fn process(handler: Arc<dyn Handler>) {
    tokio::spawn(async move {
        handler.handle(req)  // Error: Handler is not Send + Sync
    });
}
```

**Correct (recommended):**

```rust
pub trait Handler: Send + Sync + 'static {
    fn handle(&self, req: Request) -> Response;
}

async fn process(handler: Arc<dyn Handler>) {
    tokio::spawn(async move {
        handler.handle(req)  // Works!
    });
}
```

## Common Patterns

```rust
// Async handler with proper bounds
#[async_trait
pub trait AsyncHandler: Send + Sync + 'static {
    async fn handle(&self, req: Request) -> Response;
}

// Generic with bounds
pub fn spawn_handler<H>(handler: H)
where
    H: Handler + Send + Sync + 'static,
{
    tokio::spawn(async move {
        handler.handle(req).await
    });
}

// Trait object type alias
pub type DynHandler = Arc<dyn Handler + Send + Sync>;
```

## When NOT to Add These Bounds

- Single-threaded contexts (`?Send`)
- Stack-only usage (no spawning)
- Deliberately !Send types (containing `Rc`, etc.)
