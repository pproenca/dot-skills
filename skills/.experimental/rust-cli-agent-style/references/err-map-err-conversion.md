---
title: Use map_err for error type conversion
impact: MEDIUM
impactDescription: Explicit error conversion improves code clarity and control
tags: err, map_err, conversion
---

# Use map_err for error type conversion

Convert between error types using `map_err` with a closure when `#[from]` automatic conversion isn't appropriate.

## Why This Matters

- Explicit conversion is clearer than implicit
- Allows adding context during conversion
- Works when automatic `From` isn't available
- Enables error type narrowing

**Incorrect (letting errors propagate without conversion):**

```rust
// Error type mismatch - won't compile without conversion
fn parse_config(s: &str) -> Result<Config, ConfigError> {
    let value: i32 = s.parse()?;  // ParseIntError != ConfigError
    Ok(Config { value })
}
```

**Correct (explicit conversion with map_err):**

```rust
fn parse_config(s: &str) -> Result<Config, ConfigError> {
    let value: i32 = s.parse()
        .map_err(|_| ConfigError::InvalidValue(s.to_string()))?;
    Ok(Config { value })
}

// With context
fn parse_port(s: &str) -> Result<u16, ConfigError> {
    s.parse::<u16>()
        .map_err(|_| ConfigError::InvalidPort(s.to_string()))
}

// Creating io::Error from other errors
fn custom_io_operation() -> std::io::Result<()> {
    some_fallible_op()
        .map_err(|e| std::io::Error::other(format!("operation failed: {e}")))?;
    Ok(())
}
```

## Common Patterns

```rust
// String to error
.map_err(|e| Error::new(e.to_string()))

// Wrap with context
.map_err(|e| Error::Context { message: "loading config", source: e })

// Discard error details
.map_err(|_| Error::Failed)

// Convert to io::Error
.map_err(|e| io::Error::other(e))
```

## When to Use #[from] Instead

Use `#[from]` when the conversion is always appropriate and no additional context is needed.
