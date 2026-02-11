---
title: Separate Types and Errors into Dedicated Files
impact: MEDIUM
impactDescription: Dedicated files for types and errors improve discoverability and enable focused reviews
tags: mod, types, errors, file-organization
---

## Separate Types and Errors into Dedicated Files

For crates with significant type definitions or error types, place them in dedicated `types.rs` and `errors.rs` files. Re-export from lib.rs.

**Incorrect (problematic pattern):**

```rust
// lib.rs - 800 lines mixing everything
pub enum Error {
    IoError(std::io::Error),
    ParseError(String),
    // ... 20 more variants
}

pub struct CpuStat { /* 15 fields */ }
pub struct MemInfo { /* 20 fields */ }
pub struct PidInfo { /* 25 fields */ }
// ... 10 more structs

impl ProcReader {
    // ... 500 lines of implementation
}
```text

**Correct (recommended pattern):**

```
src/
├── lib.rs          # Module declarations and re-exports
├── types.rs        # All type definitions
├── errors.rs       # Error types
└── reader.rs       # Implementation
```

```rust
// lib.rs
mod types;
mod errors;
mod reader;

pub use types::*;
pub use errors::{Error, Result};
pub use reader::ProcReader;
```

```rust
// types.rs
use serde::{Deserialize, Serialize};

#[derive(Default, Clone, Debug, Serialize, Deserialize)]
pub struct CpuStat {
    pub user_usec: Option<u64>,
    pub system_usec: Option<u64>,
    pub idle_usec: Option<u64>,
}

#[derive(Default, Clone, Debug, Serialize, Deserialize)]
pub struct MemInfo {
    pub total_bytes: Option<u64>,
    pub free_bytes: Option<u64>,
}
```

```rust
// errors.rs
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("IO error reading {1:?}: {0}")]
    Io(#[source] std::io::Error, std::path::PathBuf),
    #[error("Parse error: {0}")]
    Parse(String),
}

pub type Result<T> = std::result::Result<T, Error>;
```

**When NOT to use:**
- Small crates with fewer than 5 types total
- When types and implementation are tightly coupled
