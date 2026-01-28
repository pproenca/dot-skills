---
title: Avoid _async suffix for async functions
impact: MEDIUM
impactDescription: Cleaner API - async is evident from the function signature
tags: name, async, functions
---

# Avoid _async suffix for async functions

Do not add `_async` suffix to async functions unless a sync version exists.

## Why This Matters

- The `async` keyword already indicates async
- Cleaner API surface
- Consistent with Rust ecosystem
- Suffix only needed when both versions exist

**Incorrect (avoid this pattern):**

```rust
// Redundant suffix - no sync version exists
pub async fn load_config_async() -> Result<Config> { }
pub async fn fetch_user_async(id: &str) -> Result<User> { }
pub async fn process_request_async(req: Request) -> Response { }
```

**Correct (recommended):**

```rust
// No suffix needed - async is in the signature
pub async fn load_config() -> Result<Config> { }
pub async fn fetch_user(id: &str) -> Result<User> { }
pub async fn process_request(req: Request) -> Response { }
```

## When Suffix IS Appropriate

Use suffix only when providing both sync and async versions:

```rust
// Sync version
pub fn read_file(path: &Path) -> io::Result<Vec<u8>> {
    std::fs::read(path)
}

// Async version - suffix differentiates
pub async fn read_file_async(path: &Path) -> io::Result<Vec<u8>> {
    tokio::fs::read(path).await
}

// Or use a separate async module
mod sync {
    pub fn read_file(path: &Path) -> io::Result<Vec<u8>> { }
}

mod async_api {
    pub async fn read_file(path: &Path) -> io::Result<Vec<u8>> { }
}
```
