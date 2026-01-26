---
title: Use mock! Macro for Static Methods
impact: MEDIUM
impactDescription: enables mocking types with static constructors
tags: mock, mockall, static-methods, constructors
---

## Use mock! Macro for Static Methods

Use the `mock!` macro instead of `#[automock]` when you need to mock static methods, associated functions, or types with complex generics.

**Incorrect (automock doesn't support static methods):**

```rust
#[automock]  // Error: cannot mock static methods
pub trait FileSystem {
    fn read(&self, path: &str) -> Result<String, Error>;

    // Static method - automock can't handle this
    fn exists(path: &str) -> bool;
}
```

**Correct (mock! macro for static methods):**

```rust
pub trait FileSystem {
    fn read(&self, path: &str) -> Result<String, Error>;
}

impl dyn FileSystem {
    pub fn exists(path: &str) -> bool {
        std::path::Path::new(path).exists()
    }
}

// Use mock! for static methods
mock! {
    pub FileSystem {}

    impl FileSystem for FileSystem {
        fn read(&self, path: &str) -> Result<String, Error>;
    }

    impl FileSystem {
        fn exists(path: &str) -> bool;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_file_if_exists() {
        let ctx = MockFileSystem::exists_context();
        ctx.expect()
            .with(eq("/config.toml"))
            .returning(|_| true);

        let mut mock_fs = MockFileSystem::new();
        mock_fs.expect_read()
            .with(eq("/config.toml"))
            .returning(|_| Ok("key = value".to_string()));

        let config = load_config(mock_fs).unwrap();
        assert_eq!(config.get("key"), Some("value"));
    }
}
```

**Mocking constructors:**

```rust
mock! {
    pub Database {
        pub fn connect(url: &str) -> Result<Self, Error>;
        pub fn query(&self, sql: &str) -> Result<Rows, Error>;
    }
}

#[test]
fn handles_connection_failure() {
    let ctx = MockDatabase::connect_context();
    ctx.expect()
        .with(eq("invalid://url"))
        .returning(|_| Err(Error::ConnectionFailed));

    let result = app_init("invalid://url");
    assert!(result.is_err());
}
```

**When to use mock! vs #[automock]:**

| Use `#[automock]` | Use `mock!` |
|-------------------|-------------|
| Simple traits | Static/associated methods |
| No static methods | Constructors (Self return) |
| No complex generics | Structs without traits |
| Quick setup | Full control needed |

Reference: [mockall - Static Methods](https://docs.rs/mockall/latest/mockall/#static-methods)
