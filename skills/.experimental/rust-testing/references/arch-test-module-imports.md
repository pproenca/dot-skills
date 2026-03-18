---
title: Use Standard Test Module Imports
impact: CRITICAL
impactDescription: ensures consistent test utilities across 100% of test modules
tags: arch, imports, pretty-assertions, test-setup
---

## Use Standard Test Module Imports

Every test module must import `use super::*;` to access the parent module's types and `use pretty_assertions::assert_eq;` for readable diffs. This standard preamble ensures all tests produce clear failure output.

**Incorrect (missing pretty_assertions, manual imports):**

```rust
#[cfg(test)]
mod tests {
    use crate::config::Config;
    use crate::config::ConfigBuilder;

    #[test]
    fn test_config_defaults() {
        let config = Config::default();
        assert_eq!(config.model, None); // std assert_eq with no colored diff
    }
}
```

**Correct (standard preamble with pretty_assertions):**

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn test_config_defaults() {
        let config = Config::default();
        assert_eq!(config.model, None); // colored diff on failure
    }
}
```
