---
title: Use tests Submodule for Unit Tests
impact: MEDIUM-HIGH
impactDescription: enables private function testing, zero runtime overhead
tags: mod, testing, organization, cfg, unit-tests
---

## Use tests Submodule for Unit Tests

Place unit tests in a `#[cfg(test)]` submodule within the same file. This allows testing private functions while excluding test code from release builds.

**Incorrect (tests in separate file, can't access private items):**

```rust
// src/parser.rs
fn parse_internal(input: &str) -> Vec<Token> {
    // Private helper - can't test from tests/parser_test.rs
}

pub fn parse(input: &str) -> Result<Ast, ParseError> {
    let tokens = parse_internal(input);
    // ...
}

// tests/parser_test.rs
// Can only test public API, not internal helpers
```

**Correct (tests submodule in same file):**

```rust
// src/parser.rs
fn parse_internal(input: &str) -> Vec<Token> {
    // Private helper
}

pub fn parse(input: &str) -> Result<Ast, ParseError> {
    let tokens = parse_internal(input);
    // ...
}

#[cfg(test)]
mod tests {
    use super::*;  // Access all items from parent, including private

    #[test]
    fn test_parse_internal_handles_empty_input() {
        let tokens = parse_internal("");
        assert!(tokens.is_empty());
    }

    #[test]
    fn test_parse_produces_valid_ast() {
        let ast = parse("let x = 1;").unwrap();
        assert_eq!(ast.statements.len(), 1);
    }
}
```

**Benefits:**
- Tests can access private implementation details
- Test code is excluded from release builds (`#[cfg(test)]`)
- Tests live next to the code they test

**Note:** Integration tests go in `tests/` directory and can only test public API.

Reference: [Testing - Rust Book](https://doc.rust-lang.org/book/ch11-03-test-organization.html)
