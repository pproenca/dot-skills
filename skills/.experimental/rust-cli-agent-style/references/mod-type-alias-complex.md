---
title: Create type aliases for complex generic types
impact: MEDIUM
impactDescription: Type aliases improve readability of complex nested generics
tags: mod, types, aliases
---

# Create type aliases for complex generic types

Define type aliases for nested generics to improve readability.

## Why This Matters

- Complex types become readable
- Single point of change
- Self-documenting code
- Reduces cognitive load

**Incorrect (avoid this pattern):**

```rust
// Hard to read and error-prone
fn get_pending() -> Arc<Mutex<HashMap<ThreadId, VecDeque<Event>>>> {
    // ...
}

fn process(
    data: Arc<RwLock<HashMap<String, Vec<Box<dyn Handler + Send + Sync>>>>>,
) {
    // ...
}
```

**Correct (recommended):**

```rust
// Clear type aliases
pub(crate) type PendingEvents = Arc<Mutex<HashMap<ThreadId, VecDeque<Event>>>>;
pub(crate) type HandlerRegistry = Arc<RwLock<HashMap<String, Vec<BoxedHandler>>>>;
pub type BoxedHandler = Box<dyn Handler + Send + Sync>;

fn get_pending() -> PendingEvents {
    // ...
}

fn process(handlers: HandlerRegistry) {
    // ...
}
```

## Common Patterns

```rust
// Result aliases
pub type Result<T> = std::result::Result<T, Error>;
pub type IoResult<T> = std::io::Result<T>;

// Callback types
pub type Callback = Box<dyn Fn(Event) + Send + Sync>;
pub type AsyncCallback = Box<dyn Fn(Event) -> BoxFuture<'static, ()> + Send + Sync>;

// Collection types
pub type EventQueue = VecDeque<Event>;
pub type HandlerMap = HashMap<String, BoxedHandler>;

// Pinned futures
pub type BoxFuture<'a, T> = Pin<Box<dyn Future<Output = T> + Send + 'a>>;
```

## When to Create Aliases

Create aliases when:
- Type has 3+ levels of nesting
- Type is used in multiple places
- Type represents a domain concept
- Type signature exceeds ~60 characters
