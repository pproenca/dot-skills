---
title: Use test-context for Setup and Teardown
impact: MEDIUM
impactDescription: ensures cleanup runs even on test failure
tags: fix, test-context, setup, teardown, cleanup
---

## Use test-context for Setup and Teardown

Use `test-context` crate when you need guaranteed cleanup after tests, even on panic. Implement `TestContext` trait for setup/teardown logic.

**Incorrect (teardown skipped on panic):**

```rust
#[test]
fn test_database_operation() {
    let db = Database::connect().unwrap();
    db.create_table("test_users").unwrap();

    let result = db.insert_user(&user);
    assert!(result.is_ok());  // If this panics...

    db.drop_table("test_users").unwrap();  // This never runs!
}
```

**Correct (test-context ensures teardown):**

```rust
use test_context::{test_context, TestContext};

struct DatabaseContext {
    db: Database,
    table_name: String,
}

impl TestContext for DatabaseContext {
    fn setup() -> Self {
        let db = Database::connect().unwrap();
        let table_name = format!("test_{}", uuid::Uuid::new_v4());
        db.create_table(&table_name).unwrap();
        Self { db, table_name }
    }

    fn teardown(self) {
        // Guaranteed to run even if test panics
        self.db.drop_table(&self.table_name).unwrap();
        self.db.disconnect();
    }
}

#[test_context(DatabaseContext)]
#[test]
fn test_insert_user(ctx: &mut DatabaseContext) {
    let result = ctx.db.insert_user(&ctx.table_name, &user);
    assert!(result.is_ok());
    // Table dropped automatically after test
}

#[test_context(DatabaseContext)]
#[test]
fn test_delete_user(ctx: &mut DatabaseContext) {
    ctx.db.insert_user(&ctx.table_name, &user).unwrap();
    ctx.db.delete_user(&ctx.table_name, user.id).unwrap();
    // Even if these panic, teardown runs
}
```

**Async context:**

```rust
use test_context::{test_context, AsyncTestContext};
use async_trait::async_trait;

struct AsyncDbContext {
    pool: PgPool,
    schema: String,
}

#[async_trait]
impl AsyncTestContext for AsyncDbContext {
    async fn setup() -> Self {
        let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
        let schema = format!("test_{}", uuid::Uuid::new_v4().to_string().replace("-", ""));
        sqlx::query(&format!("CREATE SCHEMA {}", schema))
            .execute(&pool)
            .await
            .unwrap();
        Self { pool, schema }
    }

    async fn teardown(self) {
        sqlx::query(&format!("DROP SCHEMA {} CASCADE", self.schema))
            .execute(&self.pool)
            .await
            .unwrap();
    }
}

#[test_context(AsyncDbContext)]
#[tokio::test]
async fn test_async_operation(ctx: &mut AsyncDbContext) {
    // Test using ctx.pool and ctx.schema
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
test-context = "0.3"
```

Reference: [test-context crate documentation](https://docs.rs/test-context)
