---
title: Use Info suffix for read-only data structures
impact: LOW
impactDescription: Clear indication that a type is for information retrieval, not mutation
tags: name, types, data
---

# Use Info suffix for read-only data structures

Read-only data transfer types should use the `Info` suffix.

## Why This Matters

- Indicates immutable/read-only semantics
- Distinguishes from mutable state
- Clear data direction (outgoing)
- Common in status/inspection APIs

**Incorrect (avoid this pattern):**

```rust
// Unclear if these are mutable or read-only
pub struct GitStatus { }    // Can I modify this?
pub struct UserData { }     // Is this for input or output?
pub struct ServerState { }  // Am I supposed to change this?
```

**Correct (recommended):**

```rust
/// Read-only information about the git repository.
#[derive(Debug, Clone)
pub struct GitInfo {
    pub branch: String,
    pub commit_hash: String,
    pub is_dirty: bool,
    pub remotes: Vec<String>,
}

/// Read-only user profile information.
#[derive(Debug, Clone, Serialize)
pub struct UserInfo {
    pub id: String,
    pub email: String,
    pub created_at: DateTime<Utc>,
}

/// Read-only model provider information.
#[derive(Debug, Clone, Serialize)
pub struct ModelProviderInfo {
    pub name: String,
    pub models: Vec<String>,
    pub is_available: bool,
}

// Usage
fn get_git_info(repo: &Repository) -> GitInfo { }
fn get_user_info(user_id: &str) -> Result<UserInfo> { }
fn list_providers() -> Vec<ModelProviderInfo> { }
```

## Related Patterns

| Suffix | Use Case | Mutability |
|--------|----------|------------|
| `Info` | Status/inspection data | Read-only |
| `State` | Runtime state | Mutable |
| `Data` | Generic data container | Varies |
| `Details` | Expanded information | Read-only |
