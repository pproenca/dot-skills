---
title: Pair Request/Response types
impact: MEDIUM
impactDescription: Consistent API type pairing improves code navigation and understanding
tags: name, api, types
---

# Pair Request/Response types

API types should come in Request/Response pairs with matching prefixes.

## Why This Matters

- Easy to find related types
- Clear API contract
- Consistent naming across APIs
- Self-documenting code

**Incorrect (avoid this pattern):**

```rust
// Inconsistent naming
pub struct UserData { }           // Request?
pub struct UserResult { }         // Response?
pub struct CreateUserInput { }    // Input?
pub struct UserOutput { }         // Output?
```

**Correct (recommended):**

```rust
// Consistent Request/Response pairing
#[derive(Debug, Serialize, Deserialize)
pub struct CreateUserRequest {
    pub email: String,
    pub name: String,
}

#[derive(Debug, Serialize, Deserialize)
pub struct CreateUserResponse {
    pub user_id: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)
pub struct GetUserRequest {
    pub user_id: String,
}

#[derive(Debug, Serialize, Deserialize)
pub struct GetUserResponse {
    pub user: User,
}

#[derive(Debug, Serialize, Deserialize)
pub struct ListUsersRequest {
    pub page: u32,
    pub limit: u32,
}

#[derive(Debug, Serialize, Deserialize)
pub struct ListUsersResponse {
    pub users: Vec<User>,
    pub total: u64,
}
```

## Handler Pattern

```rust
pub async fn create_user(
    req: CreateUserRequest,
) -> Result<CreateUserResponse, ApiError> {
    // ...
}

pub async fn get_user(
    req: GetUserRequest,
) -> Result<GetUserResponse, ApiError> {
    // ...
}
```

## Alternative: Input/Output for Internal APIs

```rust
// For internal, non-HTTP APIs
pub struct ProcessInput { }
pub struct ProcessOutput { }
```
