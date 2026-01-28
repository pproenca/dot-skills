---
title: Use is_/has_/should_ prefix for boolean functions
impact: MEDIUM
impactDescription: Boolean function naming follows English grammar for readability
tags: name, functions, boolean
---

# Use is_/has_/should_ prefix for boolean functions

Boolean-returning functions should use `is_`, `has_`, `should_`, or `can_` prefix.

## Why This Matters

- Reads like English
- Clear return type expectation
- Self-documenting code
- Consistent with Rust ecosystem

**Incorrect (avoid this pattern):**

```rust
fn dangerous_command(cmd: &str) -> bool { }
fn empty(list: &[T]) -> bool { }
fn valid(input: &str) -> bool { }
fn admin(user: &User) -> bool { }
fn retry(attempts: u32) -> bool { }
```

**Correct (recommended):**

```rust
fn is_dangerous_command(cmd: &str) -> bool { }
fn is_empty(list: &[T]) -> bool { }
fn is_valid(input: &str) -> bool { }
fn is_admin(user: &User) -> bool { }
fn should_retry(attempts: u32) -> bool { }
fn can_execute(user: &User, action: &Action) -> bool { }
fn has_permission(user: &User, resource: &Resource) -> bool { }
```

## Prefix Guidelines

| Prefix | Use Case | Example |
|--------|----------|---------|
| `is_` | State/property check | `is_empty()`, `is_valid()`, `is_running()` |
| `has_` | Possession/presence | `has_permission()`, `has_children()` |
| `can_` | Capability/ability | `can_execute()`, `can_read()` |
| `should_` | Decision/recommendation | `should_retry()`, `should_cache()` |
| `needs_` | Requirement | `needs_update()`, `needs_refresh()` |

## Struct Methods

```rust
impl User {
    pub fn is_admin(&self) -> bool {
        self.role == Role::Admin
    }

    pub fn has_permission(&self, perm: Permission) -> bool {
        self.permissions.contains(&perm)
    }

    pub fn can_access(&self, resource: &Resource) -> bool {
        self.has_permission(resource.required_permission())
    }
}

// Usage reads naturally
if user.is_admin() && user.can_access(&resource) {
    // ...
}
```
