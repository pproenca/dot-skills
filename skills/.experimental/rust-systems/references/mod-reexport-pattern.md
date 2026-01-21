---
title: Use pub use for Clean API Re-exports
impact: MEDIUM
impactDescription: Re-exports create clean public APIs while hiding internal module structure
tags: mod, pub-use, api, exports
---

## Use pub use for Clean API Re-exports

Use `pub use` to re-export items from submodules, creating a flat public API while maintaining organized internal structure.

**Incorrect (problematic pattern):**

```rust
// lib.rs - exposing internal structure
pub mod types;
pub mod reader;
pub mod errors;

// Users must know internal structure:
use mycrate::types::CpuStat;
use mycrate::reader::ProcReader;
use mycrate::errors::Error;
```

**Correct (recommended pattern):**

```rust
// lib.rs - clean flat API
mod types;
mod reader;
mod errors;

// Re-export for flat access
pub use types::{CpuStat, MemInfo, PidInfo};
pub use reader::ProcReader;
pub use errors::{Error, Result};

// Users get clean imports:
// use mycrate::{CpuStat, ProcReader, Result};
```

```rust
// For selective re-exports with renaming:
pub use types::InternalCpuStat as CpuStat;

// For re-exporting everything:
pub use types::*;

// For conditional re-exports:
#[cfg(feature = "advanced")]
pub use advanced_types::*;
```

**When NOT to use:**
- When internal module boundaries are part of the public API design
- When items would conflict (same name from different modules)
