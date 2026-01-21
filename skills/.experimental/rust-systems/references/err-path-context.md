---
title: Include Path Context in IO Errors
impact: HIGH
impactDescription: Path context in errors enables debugging without access to the running system
tags: err, context, path, io, debugging
---

## Include Path Context in IO Errors

Always include the file path when wrapping IO errors. Raw `std::io::Error` lacks path information, making debugging difficult.

**Incorrect (problematic pattern):**

```rust
// Path information lost
pub fn read_stats(path: &Path) -> Result<Stats> {
    let content = std::fs::read_to_string(path)?;  // Error: "No such file"
    parse(&content)
}

// Error message: "No such file or directory (os error 2)"
// Which file? No way to know!
```

**Correct (recommended pattern):**

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Failed to read {1:?}: {0}")]
    IoError(#[source] std::io::Error, PathBuf),

    #[error("Failed to parse {path:?}: {message}")]
    ParseError {
        path: PathBuf,
        message: String,
    },
}

pub fn read_stats(path: &Path) -> Result<Stats> {
    let content = std::fs::read_to_string(path)
        .map_err(|e| Error::IoError(e, path.to_path_buf()))?;

    parse(&content).map_err(|e| Error::ParseError {
        path: path.to_path_buf(),
        message: e.to_string(),
    })
}

// Error message: "Failed to read /proc/stat: No such file or directory (os error 2)"
// Clear which file failed!
```

```rust
// With anyhow for application code
use anyhow::{Context, Result};

pub fn read_stats(path: &Path) -> Result<Stats> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read {}", path.display()))?;

    parse(&content)
        .with_context(|| format!("Failed to parse {}", path.display()))
}
```

**When NOT to use:**
- When the path is already in the call chain context
- Internal functions where the caller adds context
