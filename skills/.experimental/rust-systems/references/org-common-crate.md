---
title: Use Dedicated Common Crate for Shared Utilities
impact: MEDIUM
impactDescription: Centralizes shared code, prevents duplication, and avoids scattered utils directories
tags: org, common, utilities, shared-code
---

## Use Dedicated Common Crate for Shared Utilities

Create a dedicated 'common' library crate for shared utilities instead of `utils/` or `helpers/` directories scattered throughout the project.

**Incorrect (problematic pattern):**

```text
project/
├── app/src/
│   └── utils/
│       ├── fileutil.rs
│       └── dateutil.rs
├── model/src/
│   └── helpers/
│       ├── fileutil.rs     # Duplicated!
│       └── stringutil.rs
└── view/src/
    └── utils/
        └── dateutil.rs     # Duplicated!
```text

**Correct (recommended pattern):**

```
project/
├── common/            # Single shared utilities crate
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs
│       ├── fileutil.rs
│       ├── dateutil.rs
│       ├── cliutil.rs
│       └── logutil.rs
├── model/
│   └── Cargo.toml    # depends on common
└── view/
    └── Cargo.toml    # depends on common
```

```rust
// common/src/lib.rs
pub mod fileutil;
pub mod dateutil;
pub mod cliutil;
pub mod logutil;

pub use fileutil::*;
pub use dateutil::*;
```

```rust
// Usage in other crates
use common::{get_unix_timestamp, get_hostname};
```

**When NOT to use:**
- Project-specific utilities that only one crate uses
- When the utility is tiny (1-2 functions) and embedding is simpler
