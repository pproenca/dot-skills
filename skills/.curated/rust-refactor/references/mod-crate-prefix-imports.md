---
title: Use crate Prefix for Internal Imports
impact: MEDIUM-HIGH
impactDescription: reduces import churn by 50% during refactors
tags: mod, imports, crate, organization, refactoring
---

## Use crate Prefix for Internal Imports

Prefer `crate::` over `super::` or relative paths for imports within your crate. This makes imports self-documenting and easier to refactor.

**Incorrect (relative imports, fragile):**

```rust
// src/services/user_service.rs
use super::super::models::User;
use super::super::db::Connection;
use super::auth::verify_token;

// Moving this file breaks all imports
```

**Correct (absolute crate:: imports):**

```rust
// src/services/user_service.rs
use crate::models::User;
use crate::db::Connection;
use crate::services::auth::verify_token;

// File location is explicit, easy to find references
```

**When to use each:**

| Prefix | Use When |
|--------|----------|
| `crate::` | Importing from anywhere in own crate |
| `super::` | Accessing immediate parent module only |
| `self::` | Explicit current module (rarely needed) |
| No prefix | External crates or std |

**Benefits:**
- Searching for `crate::models::User` finds all usages
- Moving files requires no import changes in other files
- Imports document where code comes from

Reference: [Path Clarity - Rust Reference](https://doc.rust-lang.org/reference/items/use-declarations.html)
