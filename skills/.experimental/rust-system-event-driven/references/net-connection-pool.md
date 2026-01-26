---
title: Use Connection Pools for Repeated Connections
impact: HIGH
impactDescription: reduces connection latency by 10-100×
tags: net, connection-pool, database, http, performance
---

## Use Connection Pools for Repeated Connections

Creating new connections is expensive (TCP handshake, TLS negotiation). Reuse connections through a pool to amortize setup cost across many requests.

**Incorrect (new connection per request):**

```rust
async fn fetch_user(user_id: u64) -> Result<User, Error> {
    let client = Client::connect("postgres://localhost/db").await?;  // 10-50ms each time!
    let row = client.query_one("SELECT * FROM users WHERE id = $1", &[&user_id]).await?;
    Ok(User::from_row(row))
}
```

**Correct (connection pool):**

```rust
use deadpool_postgres::{Config, Pool, Runtime};

struct UserRepository {
    pool: Pool,
}

impl UserRepository {
    async fn new() -> Result<Self, Error> {
        let mut cfg = Config::new();
        cfg.host = Some("localhost".into());
        cfg.dbname = Some("db".into());
        let pool = cfg.create_pool(Some(Runtime::Tokio1), NoTls)?;
        Ok(Self { pool })
    }

    async fn fetch_user(&self, user_id: u64) -> Result<User, Error> {
        let client = self.pool.get().await?;  // Reuses existing connection
        let row = client.query_one("SELECT * FROM users WHERE id = $1", &[&user_id]).await?;
        Ok(User::from_row(row))
    }
}
```

**For HTTP clients:**

```rust
// Create once, reuse for all requests
let client = reqwest::Client::builder()
    .pool_max_idle_per_host(10)
    .build()?;

// Reuse client for all requests
let response = client.get(url).send().await?;
```

Reference: [deadpool crate](https://docs.rs/deadpool/latest/deadpool/)
