---
title: Use Error suffix for error types
impact: HIGH
impactDescription: Consistent error naming enables easy identification and handling
tags: name, errors, types
---

# Use Error suffix for error types

Error types should end with `Error` to clearly identify them as error types.

## Why This Matters

- Immediately identifies error types
- Consistent with Rust ecosystem
- Easy to grep for error types
- Clear API contracts

**Incorrect (avoid this pattern):**

```rust
// Unclear these are errors
pub enum ConfigProblem { }
pub enum GitFailure { }
pub struct ParseIssue { }
pub enum NetworkException { }  // Java-ism
```

**Correct (recommended):**

```rust
pub enum ConfigError {
    #[error("failed to read config")
    ReadFailed,
    #[error("invalid format")
    InvalidFormat,
}

pub enum GitError {
    #[error("command failed")
    CommandFailed { command: String },
    #[error("not a repository")
    NotARepository,
}

pub struct ParseError {
    pub line: usize,
    pub message: String,
}

pub enum NetworkError {
    #[error("connection refused")
    ConnectionRefused,
    #[error("timeout")
    Timeout,
}
```

## Naming Patterns

| Domain | Error Type |
|--------|-----------|
| Configuration | `ConfigError` |
| Git operations | `GitError` |
| HTTP client | `HttpError`, `RequestError` |
| File system | `FsError`, `IoError` |
| Parsing | `ParseError` |
| Validation | `ValidationError` |
| Authentication | `AuthError` |
| Database | `DbError`, `QueryError` |

## Compound Errors

```rust
// Crate-level error that wraps module errors
pub enum Error {
    #[error(transparent)
    Config(#[from] ConfigError),

    #[error(transparent)
    Git(#[from] GitError),

    #[error(transparent)
    Network(#[from] NetworkError),
}
```
