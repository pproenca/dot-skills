---
title: Deny direct stdout/stderr in library code
impact: HIGH
impactDescription: Library code should use structured logging, not direct output
tags: style, logging, library
---

# Deny direct stdout/stderr in library code

Use `#![deny(clippy::print_stdout, clippy::print_stderr)]` in library crates.

## Why This Matters

- Libraries shouldn't produce output directly
- Callers control logging/output
- Enables structured logging
- Clean separation of concerns

## Configuration

In lib.rs:
```rust
#![deny(clippy::print_stdout)
#![deny(clippy::print_stderr)
```

Or in Cargo.toml (workspace-level):
```toml
[workspace.lints.clippy
print_stdout = "deny"
print_stderr = "deny"
```

**Incorrect (avoid this pattern):**

```rust
// In library code
pub fn process(data: &str) -> Result<Output> {
    println!("Processing: {}", data);  // Deny!
    eprintln!("Warning: slow path");   // Deny!
    // ...
}
```

**Correct (recommended):**

```rust
use tracing::debug;
use tracing::warn;

pub fn process(data: &str) -> Result<Output> {
    debug!(data = %data, "processing input");
    warn!("taking slow path");
    // ...
}
```

## Binary Crates

Binary crates can use print statements:

```rust
// In main.rs or bin/*.rs - OK to use print
fn main() -> Result<()> {
    let result = mylib::process("data")?;
    println!("{}", result);  // OK in binary
    Ok(())
}
```

## Exception Pattern

When print is truly needed (CLI output after TUI restore):

```rust
#[expect(clippy::print_stderr, reason = "TUI output after terminal restore")
fn print_error(msg: &str) {
    eprintln!("Error: {}", msg);
}
```
