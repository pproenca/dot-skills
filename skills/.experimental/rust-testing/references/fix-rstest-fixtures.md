---
title: Use rstest Fixtures for Test Setup
impact: MEDIUM
impactDescription: eliminates duplicate setup code across tests
tags: fix, rstest, fixtures, setup, dependency-injection
---

## Use rstest Fixtures for Test Setup

Use rstest's `#[fixture]` attribute to define reusable test setup. Fixtures are injected as function parameters, eliminating duplicate setup code.

**Incorrect (duplicated setup in each test):**

```rust
#[test]
fn test_create_user() {
    let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
    pool.migrate().await.unwrap();

    let service = UserService::new(pool);
    let user = service.create("alice@example.com").await.unwrap();
    assert_eq!(user.email, "alice@example.com");
}

#[test]
fn test_delete_user() {
    // Same setup repeated
    let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
    pool.migrate().await.unwrap();

    let service = UserService::new(pool);
    // ...
}
```

**Correct (rstest fixtures):**

```rust
use rstest::*;

#[fixture]
async fn db_pool() -> PgPool {
    let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
    pool.migrate().await.unwrap();
    pool
}

#[fixture]
async fn user_service(#[future] db_pool: PgPool) -> UserService {
    UserService::new(db_pool.await)
}

#[rstest]
#[tokio::test]
async fn test_create_user(#[future] user_service: UserService) {
    let service = user_service.await;
    let user = service.create("alice@example.com").await.unwrap();
    assert_eq!(user.email, "alice@example.com");
}

#[rstest]
#[tokio::test]
async fn test_delete_user(#[future] user_service: UserService) {
    let service = user_service.await;
    let user = service.create("bob@example.com").await.unwrap();

    service.delete(user.id).await.unwrap();
    assert!(service.find(user.id).await.is_none());
}
```

**Fixtures with parameters:**

```rust
#[fixture]
fn config(#[default("test")] env: &str) -> Config {
    Config::load(env)
}

#[rstest]
fn test_production_config(#[with("production")] config: Config) {
    assert!(config.is_production());
}

#[rstest]
fn test_default_config(config: Config) {
    // Uses default "test" environment
    assert!(!config.is_production());
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
rstest = "0.18"
```

Reference: [rstest crate documentation](https://docs.rs/rstest)
