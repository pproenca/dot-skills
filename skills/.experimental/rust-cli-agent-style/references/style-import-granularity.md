---
title: Use one item per use statement
impact: MEDIUM
impactDescription: Cleaner diffs and easier import management
tags: style, imports, formatting
---

# Use one item per use statement

Each `use` statement should import exactly one item (imports_granularity = Item).

## Why This Matters

- Cleaner git diffs
- Easy to add/remove imports
- Clear dependency visibility
- Consistent formatting

## rustfmt.toml Configuration

```toml
imports_granularity = "Item"
```

**Incorrect (avoid this pattern):**

```rust
use std::{fs, io, path::Path};
use tokio::{sync::mpsc, task::JoinHandle};
use serde::{Deserialize, Serialize};
```

**Correct (recommended):**

```rust
use std::fs;
use std::io;
use std::path::Path;

use tokio::sync::mpsc;
use tokio::task::JoinHandle;

use serde::Deserialize;
use serde::Serialize;
```

## Import Ordering

Group imports in this order (rustfmt handles this):

1. Standard library (`std::`)
2. External crates
3. Crate-internal (`crate::`, `super::`, `self::`)

```rust
// Standard library
use std::collections::HashMap;
use std::path::PathBuf;

// External crates
use serde::Deserialize;
use serde::Serialize;
use tokio::sync::mpsc;

// Crate-internal
use crate::config::Config;
use crate::error::Error;
```

## Git Diff Comparison

Adding `std::path::PathBuf`:

**Grouped (bad diff):**
```diff
-use std::{fs, io};
+use std::{fs, io, path::PathBuf};
```

**Granular (clean diff):**
```diff
 use std::fs;
 use std::io;
+use std::path::PathBuf;
```
