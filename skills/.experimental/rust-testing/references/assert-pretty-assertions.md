---
title: Use pretty_assertions for All Equality Checks
impact: CRITICAL
impactDescription: 5-10x faster failure diagnosis with colored diffs
tags: assert, pretty-assertions, diagnostics, diffs
---

## Use pretty_assertions for All Equality Checks

Import `pretty_assertions::assert_eq` in every test module. Standard `assert_eq!` prints raw `Debug` output on failure, requiring manual comparison of large structs. `pretty_assertions` produces colored, line-by-line diffs that immediately highlight the difference.

**Incorrect (standard assert_eq with opaque failure output):**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_roundtrip() {
        let expected = build_expected_config();
        let actual = Config::parse(INPUT);
        assert_eq!(expected, actual);
        // Failure: "assertion failed: `(left == right)`" + wall of Debug text
    }
}
```

**Correct (pretty_assertions with colored diff output):**

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn test_config_roundtrip() {
        let expected = build_expected_config();
        let actual = Config::parse(INPUT);
        assert_eq!(expected, actual);
        // Failure: colored diff showing exactly which fields differ
    }
}
```
