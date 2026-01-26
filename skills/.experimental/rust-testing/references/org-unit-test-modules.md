---
title: Use cfg(test) Modules for Unit Tests
impact: CRITICAL
impactDescription: prevents test code in production binaries
tags: org, unit-tests, cfg-test, modules
---

## Use cfg(test) Modules for Unit Tests

Place unit tests in a `#[cfg(test)]` module within the same file as the code under test. This enables testing private functions and ensures test code is excluded from production builds.

**Incorrect (tests in separate file, cannot test private functions):**

```rust
// src/parser.rs
fn parse_header(input: &str) -> Option<Header> {
    // Private helper function
    let trimmed = input.trim();
    Header::from_str(trimmed).ok()
}

pub fn parse_document(input: &str) -> Document {
    let header = parse_header(input).unwrap_or_default();
    Document::new(header)
}

// tests/parser_tests.rs
use mylib::parse_document;

#[test]
fn test_parse_document() {
    // Cannot test parse_header - it's private!
    let doc = parse_document("Title: Hello");
    assert!(doc.header.is_some());
}
```

**Correct (tests in cfg(test) module, can test private functions):**

```rust
// src/parser.rs
fn parse_header(input: &str) -> Option<Header> {
    let trimmed = input.trim();
    Header::from_str(trimmed).ok()
}

pub fn parse_document(input: &str) -> Document {
    let header = parse_header(input).unwrap_or_default();
    Document::new(header)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_header_with_whitespace() {
        let result = parse_header("  Title: Hello  ");
        assert_eq!(result.unwrap().title, "Hello");
    }

    #[test]
    fn test_parse_document() {
        let doc = parse_document("Title: Hello");
        assert!(doc.header.is_some());
    }
}
```

**Benefits:**
- Test code excluded from release builds (smaller binary, faster compilation)
- Direct access to private functions and implementation details
- Tests live next to the code they test, improving discoverability

Reference: [The Rust Book - Test Organization](https://doc.rust-lang.org/book/ch11-03-test-organization.html)
