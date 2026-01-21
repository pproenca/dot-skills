---
title: Use async_trait for Async Trait Methods
impact: MEDIUM
impactDescription: async_trait enables async methods in traits until native support stabilizes
tags: type, async, trait, async-trait
---

## Use async_trait for Async Trait Methods

Use the `#[async_trait]` macro for traits with async methods. Use associated types for the return data.

**Incorrect (problematic pattern):**

```rust
// Won't compile - async fn not allowed in traits (without boxing)
trait Collector {
    async fn collect(&mut self) -> Result<Data>;
}

// Manual boxing - verbose and error-prone
trait Collector {
    fn collect(&mut self) -> Pin<Box<dyn Future<Output = Result<Data>> + Send + '_>>;
}
```

**Correct (recommended pattern):**

```rust
use async_trait::async_trait;

#[async_trait]
pub trait AsyncCollectorPlugin: Send + Sync {
    type T;  // Associated type for collected data

    async fn try_collect(&mut self) -> Result<Option<Self::T>>;
}

// Implementation
struct GpuCollector {
    reader: GpuReader,
}

#[async_trait]
impl AsyncCollectorPlugin for GpuCollector {
    type T = GpuStats;

    async fn try_collect(&mut self) -> Result<Option<Self::T>> {
        let stats = self.reader.read_async().await?;
        Ok(Some(stats))
    }
}

// Usage
async fn collect_all(collectors: &mut [Box<dyn AsyncCollectorPlugin<T = Stats>>]) {
    for collector in collectors {
        if let Ok(Some(stats)) = collector.try_collect().await {
            process(stats);
        }
    }
}
```

```toml
# Cargo.toml
[dependencies]
async-trait = "0.1"
```

**When NOT to use:**
- When you can use concrete async functions instead of traits
- Performance-critical hot paths (async_trait adds allocation)
- When native async traits are available (Rust 1.75+)
