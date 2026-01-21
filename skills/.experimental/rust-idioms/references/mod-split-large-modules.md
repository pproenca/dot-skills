---
title: Split Large Modules into Submodules
impact: MEDIUM-HIGH
impactDescription: improves navigation, enables parallel compilation
tags: mod, organization, submodules, structure, maintainability
---

## Split Large Modules into Submodules

Break large modules (>500 lines) into focused submodules. This improves navigation and enables the compiler to parallelize work.

**Incorrect (monolithic module):**

```rust
// src/user.rs - 2000+ lines
pub struct User { /* ... */ }
pub struct UserProfile { /* ... */ }
pub struct UserPreferences { /* ... */ }

impl User {
    pub fn new() -> Self { /* 50 lines */ }
    pub fn authenticate() -> Result<()> { /* 100 lines */ }
    pub fn update_profile() -> Result<()> { /* 80 lines */ }
    // ... 50 more methods
}

pub fn validate_email() { /* ... */ }
pub fn hash_password() { /* ... */ }
// ... many more functions
```

**Correct (focused submodules):**

```rust
// src/user/mod.rs
mod auth;
mod profile;
mod validation;

pub use auth::authenticate;
pub use profile::{UserProfile, UserPreferences};
pub use validation::validate_email;

pub struct User { /* ... */ }

impl User {
    pub fn new() -> Self { /* ... */ }
}

// src/user/auth.rs
use super::User;

pub fn authenticate(user: &User, password: &str) -> Result<Token, AuthError> {
    let hash = super::validation::hash_password(password);
    // ...
}

// src/user/profile.rs
pub struct UserProfile { /* ... */ }
pub struct UserPreferences { /* ... */ }

// src/user/validation.rs
pub fn validate_email(email: &str) -> bool { /* ... */ }
pub(super) fn hash_password(password: &str) -> String { /* ... */ }
```

**Guidelines:**
- One primary type per module
- Group related functionality together
- Use `pub(super)` for internal helpers
- Keep modules under 500 lines

Reference: [Packages, Crates, and Modules - Rust Book](https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html)
