---
title: Organize integration tests in suite directory
impact: MEDIUM
impactDescription: Structured test organization improves maintainability and test discovery
tags: org, testing, integration
---

# Organize integration tests in suite directory

Place integration tests in `tests/suite/` directory with `mod.rs` for organization.

## Why This Matters

- Separates integration tests from unit tests
- Groups related tests together
- Clearer test structure for large projects
- Easy to run specific test suites

**Incorrect (scattered test files):**

```text
crate/
├── src/
│   └── lib.rs
└── tests/
    ├── test_api.rs          # Flat structure
    ├── test_config.rs       # Hard to manage
    ├── test_integration.rs  # No organization
    └── helpers.rs           # Mixed with tests
```

**Correct (suite directory structure):**

```text
crate/
├── src/
│   └── lib.rs
└── tests/
    ├── common/        # Shared test utilities (if crate-specific)
    │   └── mod.rs
    └── suite/
        ├── mod.rs     # Re-exports test modules
        ├── api_tests.rs
        ├── config_tests.rs
        └── integration_tests.rs
```

## tests/suite/mod.rs

```rust
//! Integration test suite for the crate.

mod api_tests;
mod config_tests;
mod integration_tests;
```

## Test File Example

```rust
// tests/suite/api_tests.rs
use crate::common::*;  // If you have shared utilities

#[tokio::test]
async fn test_api_endpoint() {
    // Integration test
}

#[tokio::test]
async fn test_api_error_handling() {
    // Another integration test
}
```

## Running Tests

```bash
# Run all tests
cargo test

# Run only integration tests
cargo test --test suite

# Run specific test file
cargo test --test suite::api_tests
```

## Alternative: Flat tests/ Structure

For smaller crates, a flat structure is acceptable:

```text
crate/
└── tests/
    ├── api_tests.rs
    └── config_tests.rs
```
