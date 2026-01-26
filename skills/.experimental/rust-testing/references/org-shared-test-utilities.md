---
title: Use tests/common/mod.rs for Shared Test Utilities
impact: CRITICAL
impactDescription: prevents duplicate test setup code
tags: org, test-utilities, shared-code, modules
---

## Use tests/common/mod.rs for Shared Test Utilities

Place shared test utilities in `tests/common/mod.rs` to share setup code between integration test files. Cargo treats `tests/common/mod.rs` as a submodule, not a test file.

**Incorrect (duplicated setup in each test file):**

```rust
// tests/user_tests.rs
fn setup_database() -> Database {
    let db = Database::new("postgres://localhost/test").unwrap();
    db.migrate().unwrap();
    db.seed_test_data().unwrap();
    db
}

#[test]
fn test_create_user() {
    let db = setup_database();
    // ...
}

// tests/order_tests.rs
fn setup_database() -> Database {
    // Exact same code duplicated!
    let db = Database::new("postgres://localhost/test").unwrap();
    db.migrate().unwrap();
    db.seed_test_data().unwrap();
    db
}

#[test]
fn test_create_order() {
    let db = setup_database();
    // ...
}
```

**Correct (shared utilities in common module):**

```rust
// tests/common/mod.rs
use mylib::Database;

pub fn setup_database() -> Database {
    let db = Database::new("postgres://localhost/test").unwrap();
    db.migrate().unwrap();
    db.seed_test_data().unwrap();
    db
}

pub fn create_test_user(db: &Database) -> User {
    db.create_user("test@example.com", "Test User").unwrap()
}

// tests/user_tests.rs
mod common;

#[test]
fn test_create_user() {
    let db = common::setup_database();
    let user = common::create_test_user(&db);
    assert_eq!(user.email, "test@example.com");
}

// tests/order_tests.rs
mod common;

#[test]
fn test_create_order() {
    let db = common::setup_database();
    let user = common::create_test_user(&db);
    // ...
}
```

**Directory structure:**

```text
tests/
├── common/
│   └── mod.rs      # Shared utilities - NOT run as a test
├── user_tests.rs   # Uses common::setup_database()
└── order_tests.rs  # Uses common::setup_database()
```

**Note:** Files directly in `tests/` are compiled as test crates. Subdirectories like `tests/common/` are treated as modules and won't be run as tests.

Reference: [The Rust Book - Submodules in Integration Tests](https://doc.rust-lang.org/book/ch11-03-test-organization.html#submodules-in-integration-tests)
