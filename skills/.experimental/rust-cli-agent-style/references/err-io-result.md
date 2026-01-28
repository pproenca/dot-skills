---
title: Use std::io::Result for I/O functions
impact: MEDIUM
impactDescription: Standard I/O result type for consistency with ecosystem
tags: err, io, result
---

# Use std::io::Result for I/O functions

Functions primarily doing I/O operations should return `std::io::Result` for consistency with the Rust ecosystem.

## Why This Matters

- Standard type that all Rust I/O code expects
- Easy composition with other I/O functions
- Well-understood error semantics
- Interoperates with `?` operator

**Incorrect (avoid this pattern):**

```rust
// Custom error for simple I/O
fn read_file(path: &Path) -> Result<String, MyError> {
    fs::read_to_string(path).map_err(MyError::Io)
}

// Stringly-typed errors
fn write_data(path: &Path, data: &[u8]) -> Result<(), String> {
    fs::write(path, data).map_err(|e| e.to_string())
}
```

**Correct (recommended):**

```rust
use std::io::{self, Read, Write};

// Pure I/O functions use std::io::Result
fn read_file(path: &Path) -> io::Result<String> {
    fs::read_to_string(path)
}

fn write_data(path: &Path, data: &[u8]) -> io::Result<()> {
    fs::write(path, data)
}

// I/O with additional processing can still use io::Result
fn copy_with_transform<R: Read, W: Write>(
    reader: &mut R,
    writer: &mut W,
    transform: impl Fn(&[u8]) -> Vec<u8>,
) -> io::Result<u64> {
    let mut buf = [0u8; 8192];
    let mut total = 0u64;
    loop {
        let n = reader.read(&mut buf)?;
        if n == 0 { break; }
        let transformed = transform(&buf[..n]);
        writer.write_all(&transformed)?;
        total += n as u64;
    }
    Ok(total)
}
```

## When to Use Domain Error Instead

When the function does more than I/O:

```rust
// This does I/O AND parsing, so domain error is appropriate
fn load_config(path: &Path) -> Result<Config, ConfigError> {
    let content = fs::read_to_string(path)
        .map_err(|e| ConfigError::ReadFailed { source: e })?;
    toml::from_str(&content)
        .map_err(ConfigError::ParseFailed)
}
```
