---
title: Use #[source] for Error Chaining
impact: MEDIUM
impactDescription: Source attributes enable error chain traversal for debugging
tags: err, thiserror, source, error-chain
---

## Use #[source] for Error Chaining

Mark inner errors with `#[source]` attribute in thiserror enums to preserve error chains. This enables debugging with full context.

**Incorrect (problematic pattern):**

```rust
#[derive(Debug, Error)]
pub enum Error {
    #[error("IO error: {0:?}")]
    IoError(std::io::Error),  // No source - chain broken

    #[error("Network error: {0}")]
    Network(String),  // Error converted to string - chain lost
}

// When printed: "IO error: Os { code: 2, ... }"
// Can't programmatically access underlying error
```

**Correct (recommended pattern):**

```rust
#[derive(Debug, Error)]
pub enum Error {
    // #[source] preserves error chain
    #[error("Failed to read {path:?}")]
    IoError {
        #[source]
        source: std::io::Error,
        path: PathBuf,
    },

    // #[from] implies #[source] and enables ?
    #[error("JSON error")]
    Json(#[from] serde_json::Error),

    // Wrapping another crate's error
    #[error("Database error: {0}")]
    Database(#[source] diesel::result::Error),
}

// Full chain accessible
fn show_error(e: &Error) {
    eprintln!("Error: {}", e);

    let mut source = e.source();
    while let Some(cause) = source {
        eprintln!("Caused by: {}", cause);
        source = cause.source();
    }
}

// Output:
// Error: Failed to read "/etc/config.json"
// Caused by: No such file or directory (os error 2)
```

```rust
// With anyhow for printing full chains
fn main() -> anyhow::Result<()> {
    if let Err(e) = run() {
        // Prints full error chain with {:#}
        eprintln!("Error: {:#}", e);
        std::process::exit(1);
    }
    Ok(())
}
```

**When NOT to use:**
- When the inner error provides no useful additional context
- Leaf errors that don't wrap other errors
