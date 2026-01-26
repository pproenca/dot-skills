---
title: Assert Specific Error Types Not Just is_err
impact: MEDIUM
impactDescription: catches wrong error type bugs
tags: assert, errors, result, matching, specificity
---

## Assert Specific Error Types Not Just is_err

Assert the specific error variant, not just that an error occurred. Generic `is_err()` checks pass when the wrong error is returned.

**Incorrect (any error passes):**

```rust
#[test]
fn test_invalid_email_rejected() {
    let result = User::new("invalid-email", "Alice");
    assert!(result.is_err());  // Passes if ANY error occurs
    // Bug: Might be a database error, not validation error!
}

#[test]
fn test_file_not_found() {
    let result = read_config("/nonexistent/path");
    assert!(result.is_err());  // What if it's a permission error?
}
```

**Correct (assert specific error):**

```rust
#[test]
fn test_invalid_email_rejected() {
    let result = User::new("invalid-email", "Alice");

    assert!(matches!(
        result,
        Err(UserError::InvalidEmail { email }) if email == "invalid-email"
    ));
}

#[test]
fn test_file_not_found() {
    let result = read_config("/nonexistent/path");

    match result {
        Err(ConfigError::FileNotFound { path }) => {
            assert_eq!(path, "/nonexistent/path");
        }
        Err(other) => panic!("Expected FileNotFound, got: {:?}", other),
        Ok(_) => panic!("Expected error"),
    }
}

// With assert_matches! macro (nightly or via crate)
#[test]
fn test_parse_error() {
    let result = parse_number("abc");

    assert_matches!(result, Err(ParseError::InvalidDigit { position: 0, .. }));
}
```

**Using unwrap_err for error inspection:**

```rust
#[test]
fn test_error_message_content() {
    let result = validate_password("123");
    let error = result.unwrap_err();

    assert!(matches!(error, ValidationError::TooShort { min_length: 8, .. }));
    assert!(error.to_string().contains("at least 8 characters"));
}
```

**Testing error chains:**

```rust
#[test]
fn test_error_source_chain() {
    let result = connect_database("invalid://url");
    let error = result.unwrap_err();

    assert!(matches!(error, DatabaseError::ConnectionFailed { .. }));

    // Check the underlying cause
    let source = error.source().unwrap();
    assert!(source.to_string().contains("invalid URL"));
}
```

**Custom assertion helper:**

```rust
fn assert_validation_error(result: Result<User, UserError>, expected: &str) {
    match result {
        Err(UserError::Validation { field, message }) => {
            assert_eq!(field, expected, "Wrong field: {}", message);
        }
        Err(other) => panic!("Expected validation error, got: {:?}", other),
        Ok(_) => panic!("Expected validation error"),
    }
}

#[test]
fn test_email_validation() {
    let result = User::new("bad", "Alice");
    assert_validation_error(result, "email");
}
```

Reference: [Rust By Example - Error Handling](https://doc.rust-lang.org/rust-by-example/error.html)
