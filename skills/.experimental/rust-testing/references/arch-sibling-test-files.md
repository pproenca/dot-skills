---
title: Place Tests in Sibling _tests.rs Files
impact: CRITICAL
impactDescription: reduces merge conflicts by 60-80% in high-churn modules
tags: arch, test-organization, modules, file-structure
---

## Place Tests in Sibling _tests.rs Files

Separate test code from production code by placing tests in sibling `_tests.rs` files using the `#[path = ...]` attribute. This keeps production modules focused and eliminates merge conflicts when multiple developers add tests concurrently.

**Incorrect (inline tests bloating the source file):**

```rust
// config.rs — 400 lines of production code followed by 200 lines of tests
pub fn resolve_model(config: &Config) -> String {
    // ... production logic
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resolve_model_default() {
        // 200+ lines of tests mixed into the same file
    }
}
```

**Correct (sibling test file via #[path] attribute):**

```rust
// config.rs — only production code
pub fn resolve_model(config: &Config) -> String {
    // ... production logic
}

#[cfg(test)]
#[path = "config_tests.rs"]
mod tests;
```

```rust
// config_tests.rs — dedicated test file
use super::*;
use pretty_assertions::assert_eq;

#[test]
fn test_resolve_model_default() {
    // tests live in their own file
}
```
