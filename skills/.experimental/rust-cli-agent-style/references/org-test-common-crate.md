---
title: Create separate crate for shared test utilities
impact: MEDIUM
impactDescription: Shared test utilities reduce duplication and enable consistent testing patterns
tags: org, testing, utilities
---

# Create separate crate for shared test utilities

Place shared test utilities in `tests/common/` as a separate workspace member crate.

## Why This Matters

- Avoids duplicating test helpers across crates
- Consistent test patterns across workspace
- Proper dependency management for test code
- Cleaner test module organization

**Incorrect (duplicated test helpers):**

```rust
// core/tests/integration_tests.rs
fn setup_test_dir() -> tempfile::TempDir {
    tempfile::tempdir().expect("test setup")
}

// cli/tests/cli_tests.rs
fn setup_test_dir() -> tempfile::TempDir {  // Duplicated!
    tempfile::tempdir().expect("test setup")
}
```

**Correct (shared test crate):**

```text
workspace/
├── core/
│   └── tests/
│       └── integration_tests.rs
├── cli/
│   └── tests/
│       └── cli_tests.rs
└── tests/
    └── common/
        ├── Cargo.toml
        └── src/
            └── lib.rs
```

## tests/common/Cargo.toml

```toml
[package]
name = "codex-test-common"
version = "0.1.0"
edition = "2024"
publish = false  # Never publish test utilities

[dependencies]
tokio = { workspace = true }
tempfile = "3"
assert_matches = "1"

# Crates being tested
codex-core = { path = "../../core" }
codex-protocol = { path = "../../protocol" }
```

## tests/common/src/lib.rs

```rust
//! Shared test utilities for the codex workspace.

pub mod fixtures;
pub mod mocks;
pub mod assertions;

/// Creates a temporary directory with test fixtures.
pub fn setup_test_dir() -> tempfile::TempDir {
    tempfile::tempdir().expect("test setup")
}

/// Mock server for testing client code.
pub struct MockServer {
    // ...
}
```

## Using in Tests

```rust
// In core/tests/integration_tests.rs
use codex_test_common::{setup_test_dir, MockServer};

#[tokio::test]
async fn test_client_connection() {
    let server = MockServer::start().await;
    let dir = setup_test_dir();
    // ...
}
```
