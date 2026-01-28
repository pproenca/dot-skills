---
title: Place handlers in dedicated subdirectory
impact: MEDIUM
impactDescription: Separating handlers from core logic improves code organization
tags: org, handlers, modules
---

# Place handlers in dedicated subdirectory

When a module has multiple handlers, place them in a `handlers/` subdirectory with `mod.rs`.

## Why This Matters

- Separates dispatch logic from implementation
- Easy to find all handlers for a feature
- Clear naming convention
- Scales as handlers grow

**Incorrect (handlers mixed with other code):**

```text
src/api/
├── mod.rs
├── router.rs
├── auth_handler.rs      # Mixed with other files
├── user_handler.rs
├── task_handler.rs
├── context.rs
└── middleware.rs
```

**Correct (handlers in subdirectory):**

```text
src/api/
├── mod.rs           # API module root
├── router.rs        # Request routing
├── context.rs
├── middleware.rs
└── handlers/
    ├── mod.rs       # Handler exports
    ├── auth.rs      # Auth handlers
    ├── users.rs     # User handlers
    └── tasks.rs     # Task handlers
```

## handlers/mod.rs

```rust
//! API request handlers.

mod auth;
mod users;
mod tasks;

pub use auth::*;
pub use users::*;
pub use tasks::*;
```

## Handler Pattern

```rust
// handlers/users.rs
use crate::api::context::ApiContext;
use crate::api::error::ApiError;

pub async fn get_user(
    ctx: &ApiContext,
    user_id: &str,
) -> Result<User, ApiError> {
    ctx.db.find_user(user_id).await
        .ok_or(ApiError::NotFound)
}

pub async fn create_user(
    ctx: &ApiContext,
    input: CreateUserInput,
) -> Result<User, ApiError> {
    // Validation and creation logic
}
```

## Router Integration

```rust
// router.rs
use crate::api::handlers;

pub fn setup_routes(router: Router) -> Router {
    router
        .route("/users/:id", get(handlers::get_user))
        .route("/users", post(handlers::create_user))
}
```
