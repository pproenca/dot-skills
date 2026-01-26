---
title: Place Integration Tests in tests Directory
impact: CRITICAL
impactDescription: ensures tests use only public API
tags: org, integration-tests, directory-structure, public-api
---

## Place Integration Tests in tests Directory

Integration tests belong in a top-level `tests/` directory, not alongside source code. Each file in `tests/` is compiled as a separate crate, ensuring tests only access the public API.

**Incorrect (integration tests mixed with unit tests):**

```rust
// src/lib.rs
pub struct Database {
    connection: Connection,
}

impl Database {
    pub fn new(url: &str) -> Result<Self, Error> { /* ... */ }
    pub fn query(&self, sql: &str) -> Result<Rows, Error> { /* ... */ }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_database_integration() {
        // This test requires a real database but is in the unit test module
        let db = Database::new("postgres://localhost/test").unwrap();
        let rows = db.query("SELECT 1").unwrap();  // Slow, requires setup
        assert_eq!(rows.len(), 1);
    }
}
```

**Correct (integration tests in tests directory):**

```rust
// src/lib.rs
pub struct Database {
    connection: Connection,
}

impl Database {
    pub fn new(url: &str) -> Result<Self, Error> { /* ... */ }
    pub fn query(&self, sql: &str) -> Result<Rows, Error> { /* ... */ }
}

// tests/database_integration.rs
use mylib::Database;

#[test]
fn test_database_query() {
    let db = Database::new("postgres://localhost/test").unwrap();
    let rows = db.query("SELECT 1").unwrap();
    assert_eq!(rows.len(), 1);
}

#[test]
fn test_database_transaction() {
    let db = Database::new("postgres://localhost/test").unwrap();
    // Test transaction behavior through public API only
}
```

**Directory structure:**

```text
my_crate/
├── Cargo.toml
├── src/
│   └── lib.rs
└── tests/
    ├── database_integration.rs
    └── api_integration.rs
```

**Benefits:**
- Clear separation between fast unit tests and slow integration tests
- Run only integration tests with `cargo test --test database_integration`
- Tests verify the public API works correctly

Reference: [Rust By Example - Integration Testing](https://doc.rust-lang.org/rust-by-example/testing/integration_testing.html)
