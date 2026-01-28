---
title: Use Handler suffix for trait implementations
impact: MEDIUM
impactDescription: Clear naming indicates the purpose of handler types
tags: name, handlers, traits
---

# Use Handler suffix for trait implementations

Types that implement handler traits should use the `Handler` suffix.

## Why This Matters

- Immediately identifies purpose
- Consistent pattern across codebase
- Easy to find all handlers
- Clear relationship with trait

**Incorrect (avoid this pattern):**

```rust
// Unclear what these types do
pub struct Git { }
pub struct Shell { }
pub struct FileOps { }

impl Tool for Git { }
impl Tool for Shell { }
impl EventProcessor for FileOps { }
```

**Correct (recommended):**

```rust
// Clear handler naming
pub struct GitToolHandler { }
pub struct ShellToolHandler { }
pub struct FileEventHandler { }

impl Tool for GitToolHandler { }
impl Tool for ShellToolHandler { }
impl EventProcessor for FileEventHandler { }
```

## Common Handler Patterns

```rust
// Request handlers
pub struct AuthHandler { }
pub struct ApiRequestHandler { }

// Event handlers
pub struct KeyboardEventHandler { }
pub struct MouseEventHandler { }
pub struct SystemEventHandler { }

// Message handlers
pub struct MessageHandler { }
pub struct CommandHandler { }

// Callback handlers
pub struct ResponseHandler { }
pub struct ErrorHandler { }
```

## With Generics

```rust
pub struct TypedHandler<T> {
    _marker: PhantomData<T>,
}

// Specific handler for a type
pub type UserRequestHandler = TypedHandler<UserRequest>;
pub type OrderRequestHandler = TypedHandler<OrderRequest>;
```
