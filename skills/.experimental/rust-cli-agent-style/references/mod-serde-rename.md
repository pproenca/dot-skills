---
title: Use serde rename for wire format compatibility
impact: HIGH
impactDescription: Proper serde configuration ensures API compatibility
tags: mod, serde, api, serialization
---

# Use serde rename for wire format compatibility

Apply `#[serde(rename = "...")]` or `#[serde(rename_all = "camelCase")]` for JSON APIs.

## Why This Matters

- Rust uses snake_case, JSON typically uses camelCase
- API contracts must be stable
- Self-documenting serialization format
- Avoids runtime surprises

**Incorrect (avoid this pattern):**

```rust
#[derive(Serialize, Deserialize)
pub struct ApiResponse {
    pub user_id: String,      // Serializes as "user_id"
    pub created_at: DateTime, // Serializes as "created_at"
}
// JSON: {"user_id": "...", "created_at": "..."}
// But API expects: {"userId": "...", "createdAt": "..."}
```

**Correct (recommended):**

```rust
#[derive(Debug, Clone, Serialize, Deserialize)
#[serde(rename_all = "camelCase")
pub struct ApiResponse {
    pub user_id: String,      // Serializes as "userId"
    pub created_at: DateTime, // Serializes as "createdAt"
    pub is_active: bool,      // Serializes as "isActive"
}
// JSON: {"userId": "...", "createdAt": "...", "isActive": true}
```

## Individual Field Rename

```rust
#[derive(Debug, Clone, Serialize, Deserialize)
#[serde(rename_all = "camelCase")
pub struct Message {
    pub message_id: String,

    #[serde(rename = "type")]  // "type" is a Rust keyword
    pub message_type: MessageType,

    #[serde(rename = "ID")]    // Custom casing
    pub external_id: String,
}
```

## Common Patterns

```rust
// Skip serializing None values
#[serde(skip_serializing_if = "Option::is_none")
pub optional_field: Option<String>,

// Default value on deserialize
#[serde(default)
pub count: u32,

// Flatten nested struct
#[serde(flatten)
pub metadata: Metadata,

// Enum variants as strings
#[derive(Serialize, Deserialize)
#[serde(rename_all = "SCREAMING_SNAKE_CASE")
pub enum Status {
    InProgress,  // "IN_PROGRESS"
    Completed,   // "COMPLETED"
}
```
