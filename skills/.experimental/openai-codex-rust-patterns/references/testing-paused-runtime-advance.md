---
title: Use start_paused and advance for deterministic timing tests
impact: MEDIUM-HIGH
impactDescription: eliminates wall-clock flakes from timing-dependent tests
tags: testing, async, determinism, tokio
---

## Use start_paused and advance for deterministic timing tests

Testing timeouts, retries, or debounces with real `tokio::time::sleep` calls blows wall-clock budgets and flakes under CI load. Codex marks timing tests with `#[tokio::test(start_paused = true)]` — the runtime starts with virtual time frozen. The test then spawns the unit under test, yields control once with `tokio::task::yield_now().await` to let the spawned task subscribe to the timer, and then calls `tokio::time::advance(duration).await` to jump forward deterministically. No wall-clock wait, no flakes.

**Incorrect (real sleep, flaky under load):**

```rust
#[tokio::test]
async fn times_out_after_five_seconds() {
    let handle = tokio::spawn(operation_with_timeout());
    tokio::time::sleep(Duration::from_secs(6)).await; // actual wait
    assert!(handle.await.unwrap().is_err());
}
```

**Correct (start_paused + yield + advance):**

```rust
// cloud-requirements/src/lib.rs
#[tokio::test(start_paused = true)]
async fn fetch_cloud_requirements_times_out() {
    let auth_manager = auth_manager_with_plan("enterprise");
    let codex_home = tempdir().expect("tempdir");
    let service = CloudRequirementsService::new(
        auth_manager,
        Arc::new(PendingFetcher),
        codex_home.path().to_path_buf(),
        CLOUD_REQUIREMENTS_TIMEOUT,
    );
    let handle = tokio::spawn(async move {
        service.fetch_with_timeout().await
    });
    tokio::time::advance(
        CLOUD_REQUIREMENTS_TIMEOUT + Duration::from_millis(1),
    ).await;

    let result = handle.await.expect("cloud requirements task");
    let err = result.expect_err("timeout should fail closed");
}

// The pattern when advance is called during setup:
let handle = tokio::spawn(async move { service.fetch().await });
tokio::task::yield_now().await;
tokio::time::advance(Duration::from_secs(1)).await;
```

The `yield_now()` between `spawn` and `advance` is load-bearing — without it, the spawned task has not yet registered its timer and `advance` is a no-op. This is the specific tokio idiom for paused-runtime tests and is not well documented.

Reference: `codex-rs/cloud-requirements/src/lib.rs:1308`, `codex-rs/cloud-requirements/src/lib.rs:1343`.
