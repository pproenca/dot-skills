---
title: Use join! for Concurrent Futures
impact: MEDIUM-HIGH
impactDescription: 2-5× faster for multiple independent operations
tags: async, join, concurrent, parallel, futures
---

## Use join! for Concurrent Futures

Sequential `.await` calls run one after another. Use `tokio::join!` or `futures::join!` to run independent futures concurrently.

**Incorrect (sequential execution):**

```rust
async fn fetch_dashboard_data(user_id: u64) -> DashboardData {
    let user = fetch_user(user_id).await;      // Wait for user
    let posts = fetch_posts(user_id).await;    // Then wait for posts
    let notifications = fetch_notifications(user_id).await;  // Then wait for notifications
    // Total time: user + posts + notifications
    DashboardData { user, posts, notifications }
}
```

**Correct (concurrent execution):**

```rust
use tokio::join;

async fn fetch_dashboard_data(user_id: u64) -> DashboardData {
    let (user, posts, notifications) = join!(
        fetch_user(user_id),
        fetch_posts(user_id),
        fetch_notifications(user_id),
    );
    // Total time: max(user, posts, notifications)
    DashboardData { user, posts, notifications }
}
```

**For fallible futures, use try_join!:**

```rust
use tokio::try_join;

async fn fetch_dashboard_data(user_id: u64) -> Result<DashboardData, Error> {
    let (user, posts, notifications) = try_join!(
        fetch_user(user_id),
        fetch_posts(user_id),
        fetch_notifications(user_id),
    )?;  // Returns first error encountered
    Ok(DashboardData { user, posts, notifications })
}
```

Reference: [Tokio - Async in Depth](https://tokio.rs/tokio/tutorial/async)
