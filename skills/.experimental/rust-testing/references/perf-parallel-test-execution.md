---
title: Configure Parallel Test Threads
impact: LOW-MEDIUM
impactDescription: 2-4× faster test suite on multi-core machines
tags: perf, parallel, threads, concurrency, execution
---

## Configure Parallel Test Threads

Configure the number of test threads for optimal performance. Too few wastes cores; too many causes contention.

**Incorrect (suboptimal parallelism):**

```bash
# Running memory-intensive tests with default num_cpus threads
cargo test
# All 8 cores try to allocate 1GB each
# System runs out of memory, tests fail or swap thrash
```

**Correct (tuned thread count for test type):**

```bash
# More threads for IO-bound tests
cargo test -- --test-threads=16

# Fewer threads for CPU-bound or memory-intensive tests
cargo test -- --test-threads=4

# Single-threaded for debugging race conditions
cargo test -- --test-threads=1
```

**Nextest configuration for different profiles:**

```toml
# .config/nextest.toml
[profile.default]
test-threads = "num-cpus"

[profile.low-memory]
test-threads = 4

[profile.integration]
test-threads = 1
```

```bash
cargo nextest run --profile low-memory
```

**Separate fast and slow test jobs in CI:**

```yaml
jobs:
  fast-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Fast unit tests (high parallelism)
        run: cargo nextest run -E 'not test(/slow/)' --test-threads 8

  slow-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Slow integration tests (low parallelism)
        run: cargo nextest run -E 'test(/slow/)' --test-threads 2
```

**Resource-aware test limits:**

```rust
use std::sync::Semaphore;
use once_cell::sync::Lazy;

static DB_SEMAPHORE: Lazy<Semaphore> = Lazy::new(|| Semaphore::new(4));

#[tokio::test]
async fn test_with_database() {
    let _permit = DB_SEMAPHORE.acquire().await.unwrap();
    run_database_test().await;  // Only 4 tests access DB concurrently
}
```

**Thread count guidelines:**

| Test Type | Recommended Threads |
|-----------|-------------------|
| Pure unit tests | num_cpus × 2 |
| IO-bound tests | num_cpus × 2-4 |
| CPU-bound tests | num_cpus |
| Memory-heavy tests | num_cpus / 2 |

Reference: [cargo test - Parallel Testing](https://doc.rust-lang.org/book/ch11-02-running-tests.html)
