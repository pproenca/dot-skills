---
title: Use Sibling Test Files Instead of Inline Test Modules
impact: HIGH
impactDescription: reduces production file size by 30-50% via test separation
tags: mod, tests, file-organization, test-modules
---

## Use Sibling Test Files Instead of Inline Test Modules

Place tests in a sibling file using the `#[path = "..."]` attribute instead of embedding large `#[cfg(test)] mod tests { ... }` blocks at the bottom of the source file. This keeps production code readable while maintaining test colocality.

**Incorrect (200+ line test block bloats the source file):**

```rust
// codex-rs/core/src/features.rs
pub enum Feature { /* ... */ }

impl Feature { /* ... */ }

#[cfg(test)]
mod tests {
    use super::*;
    // 200+ lines of tests embedded in the same file
    #[test]
    fn test_feature_defaults() { /* ... */ }
    #[test]
    fn test_feature_lifecycle() { /* ... */ }
}
```

**Correct (tests in a sibling file via #[path]):**

```rust
// codex-rs/core/src/features.rs
pub enum Feature { /* ... */ }

impl Feature { /* ... */ }

#[cfg(test)]
#[path = "features_tests.rs"]
mod tests;

// codex-rs/core/src/features_tests.rs
use super::*;

#[test]
fn test_feature_defaults() { /* ... */ }
#[test]
fn test_feature_lifecycle() { /* ... */ }
```
