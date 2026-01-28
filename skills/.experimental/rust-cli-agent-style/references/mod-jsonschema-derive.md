---
title: Derive JsonSchema for API types
impact: MEDIUM
impactDescription: Schema generation enables automatic API documentation and validation
tags: mod, jsonschema, api, documentation
---

# Derive JsonSchema for API types

Types used in API definitions should derive `JsonSchema` for documentation.

## Why This Matters

- Automatic OpenAPI/Swagger generation
- Client SDK generation
- Request/response validation
- Self-documenting APIs

**Incorrect (no schema derivation):**

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateUserRequest {
    pub email: String,
    pub role: UserRole,
}
// No schema available for documentation or validation
```

**Correct (with JsonSchema):**

```rust
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, JsonSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateUserRequest {
    /// The user's email address
    pub email: String,

    /// Display name (optional)
    #[serde(skip_serializing_if = "Option::is_none")]
    pub display_name: Option<String>,

    /// User role
    pub role: UserRole,
}

#[derive(Debug, Clone, Serialize, Deserialize, JsonSchema)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum UserRole {
    Admin,
    Member,
    Guest,
}
```

## Generating Schema

```rust
use schemars::schema_for;

fn main() {
    let schema = schema_for!(CreateUserRequest);
    println!("{}", serde_json::to_string_pretty(&schema).unwrap());
}
```

## With Validation Hints

```rust
#[derive(JsonSchema)]
pub struct Config {
    /// Port number (1-65535)
    #[schemars(range(min = 1, max = 65535))]
    pub port: u16,

    /// Timeout in seconds
    #[schemars(range(min = 1))]
    pub timeout_secs: u32,
}
```
