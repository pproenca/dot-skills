---
title: Use pub use for Clean Module Re-exports
impact: MEDIUM-HIGH
impactDescription: reduces import paths by 2-3 segments
tags: mod, pub-use, reexport, api, organization
---

## Use pub use for Clean Module Re-exports

Use `pub use` to re-export items at your crate root, creating a flat, intuitive API while maintaining internal module organization.

**Incorrect (users must know internal structure):**

```rust
// lib.rs
pub mod models;
pub mod services;
pub mod utils;

// Users must import deeply nested items
use mycrate::models::user::User;
use mycrate::services::auth::AuthService;
use mycrate::utils::validation::validate_email;
```

**Correct (re-export commonly used items):**

```rust
// lib.rs
mod models;
mod services;
mod utils;

// Re-export at crate root
pub use models::user::User;
pub use services::auth::AuthService;

// Or create a prelude module
pub mod prelude {
    pub use crate::models::user::User;
    pub use crate::services::auth::AuthService;
    pub use crate::utils::validation::validate_email;
}

// Users get a clean API
use mycrate::User;
use mycrate::AuthService;
// Or import everything common
use mycrate::prelude::*;
```

**Benefits:**
- Users don't depend on internal module structure
- Free to reorganize internals without breaking API
- Common items are discoverable at crate root

**Convention:** Create a `prelude` module for items meant to be glob-imported.

Reference: [Re-exports - Rust Reference](https://doc.rust-lang.org/reference/items/use-declarations.html#use-visibility)
