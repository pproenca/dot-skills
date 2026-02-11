---
title: Minimize Public API Surface
impact: MEDIUM-HIGH
impactDescription: enables internal refactoring without breaking changes
tags: mod, visibility, public, api, encapsulation
---

## Minimize Public API Surface

Keep items private by default and only expose what users need. Smaller public APIs are easier to maintain and evolve.

**Incorrect (everything public, hard to refactor):**

```rust
pub mod database {
    pub struct Connection {
        pub pool: Pool,
        pub config: Config,
        pub retry_count: u32,
    }

    pub struct Pool {
        pub connections: Vec<RawConnection>,
        pub max_size: usize,
    }

    pub fn create_raw_connection(host: &str) -> RawConnection {
        // Internal implementation detail
    }
}
```

**Correct (minimal public surface):**

```rust
pub mod database {
    pub struct Connection {
        pool: Pool,      // Private - implementation detail
        config: Config,  // Private - implementation detail
        retry_count: u32,
    }

    impl Connection {
        pub fn new(config: Config) -> Self { /* ... */ }
        pub fn query(&self, sql: &str) -> Result<Rows, Error> { /* ... */ }
    }

    struct Pool {
        connections: Vec<RawConnection>,
        max_size: usize,
    }

    fn create_raw_connection(host: &str) -> RawConnection {
        // Not pub - internal only
    }
}
```

**Visibility levels:**

| Visibility | Meaning | Use When |
|------------|---------|----------|
| (none) | Private to module | Default for internal items |
| `pub(crate)` | Visible within crate | Shared between modules |
| `pub(super)` | Visible to parent | Child module helpers |
| `pub` | Public API | User-facing only |

Reference: [Visibility - Rust Reference](https://doc.rust-lang.org/reference/visibility-and-privacy.html)
