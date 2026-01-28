---
title: Use pub(crate) for internal APIs
impact: HIGH
impactDescription: Proper visibility prevents accidental external dependencies on internal APIs
tags: org, visibility, api
---

# Use pub(crate) for internal APIs

Prefer `pub(crate)` for crate-internal functions and types over private or fully public.

## Why This Matters

- Prevents external code from depending on internals
- Makes the public API surface explicit
- Allows refactoring internal code freely
- Clearer intent than `pub` for internal use

## Visibility Levels

| Visibility | Scope | Use Case |
|-----------|-------|----------|
| `pub` | Everywhere | Public API |
| `pub(crate)` | Current crate | Internal shared code |
| `pub(super)` | Parent module | Module-internal helpers |
| (private) | Current module | Implementation details |

**Incorrect (avoid this pattern):**

```rust
// Too broad - exposes internal implementation
pub fn internal_helper() { }

// Too narrow - can't use from sibling modules
fn shared_utility() { }
```

**Correct (recommended):**

```rust
// Public API - explicitly intended for external use
pub fn process_request(req: Request) -> Response {
    let validated = validate_internal(req);
    transform_internal(validated)
}

// Internal shared code - accessible within crate only
pub(crate) fn validate_internal(req: Request) -> ValidatedRequest {
    // ...
}

pub(crate) fn transform_internal(req: ValidatedRequest) -> Response {
    // ...
}

// Module-only helper
fn helper_function() {
    // ...
}
```

## Struct Fields

```rust
pub struct Config {
    /// Public configuration option
    pub timeout: Duration,

    /// Internal field, not part of public API
    pub(crate) internal_state: State,

    /// Private implementation detail
    cache: HashMap<String, Value>,
}
```

## Re-exports

Use `pub use` to expose internal items at a higher level:

```rust
// In lib.rs
mod internal;

// Re-export specific items as public API
pub use internal::PublicType;
pub use internal::public_function;
```
