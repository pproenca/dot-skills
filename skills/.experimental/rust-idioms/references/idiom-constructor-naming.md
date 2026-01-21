---
title: Follow Constructor Naming Conventions
impact: MEDIUM
impactDescription: reduces API learning curve, enables IDE autocomplete discovery
tags: idiom, naming, constructor, convention, api
---

## Follow Constructor Naming Conventions

Use standard constructor naming patterns. Consistent names make APIs predictable and documentation unnecessary for common operations.

**Incorrect (inconsistent or unclear naming):**

```rust
impl Buffer {
    fn create() -> Self { /* ... */ }
    fn make_with_capacity(cap: usize) -> Self { /* ... */ }
    fn from_string(s: String) -> Self { /* ... */ }
    fn copy_from(other: &Buffer) -> Self { /* ... */ }
}
```

**Correct (standard naming conventions):**

```rust
impl Buffer {
    /// Creates a new empty buffer
    fn new() -> Self { /* ... */ }

    /// Creates a buffer with pre-allocated capacity
    fn with_capacity(capacity: usize) -> Self { /* ... */ }

    /// Converts a String into a Buffer, consuming it
    fn from_string(s: String) -> Self { /* ... */ }  // Or impl From<String>

    /// Creates a copy of another buffer
    fn clone_from(other: &Buffer) -> Self { /* ... */ }
}
```

**Standard constructor patterns:**

| Pattern | Meaning | Example |
|---------|---------|---------|
| `new()` | Default constructor | `Vec::new()` |
| `with_*()` | Constructor with configuration | `Vec::with_capacity(10)` |
| `from_*()` | Conversion from specific type | `String::from_utf8()` |
| `try_new()` | Fallible constructor | `File::try_new()` |
| `default()` | Default trait implementation | `Config::default()` |

**Naming for consuming vs borrowing:**

| Prefix | Takes | Returns | Example |
|--------|-------|---------|---------|
| `into_*` | `self` | Owned | `into_string()` |
| `to_*` | `&self` | Owned (clones) | `to_string()` |
| `as_*` | `&self` | Borrowed | `as_str()` |

Reference: [Naming - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/naming.html)
