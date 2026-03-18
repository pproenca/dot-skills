---
title: Handle Sandbox Environment Variables Gracefully
impact: MEDIUM
impactDescription: 100% graceful skip rate in sandboxed CI environments
tags: det, sandbox, environment, skip-macros
---

## Handle Sandbox Environment Variables Gracefully

Tests that cannot run inside a sandbox (e.g., tests that need to spawn their own Seatbelt sandbox) must use the `skip_if_sandbox!()` macro to exit gracefully. Tests that require network access must use `skip_if_no_network!()`. Never modify `CODEX_SANDBOX_*` environment variables in test code.

**Incorrect (test fails hard when running under sandbox):**

```rust
#[tokio::test]
async fn test_seatbelt_spawn() {
    let child = Command::new("sandbox-exec")
        .arg("-p").arg(PROFILE)
        .spawn().unwrap();
    // Fails when already running under Seatbelt: nested sandbox not allowed
}
```

**Correct (graceful skip when sandbox is active):**

```rust
#[tokio::test]
async fn test_seatbelt_spawn() {
    skip_if_sandbox!();
    let child = Command::new("sandbox-exec")
        .arg("-p").arg(PROFILE)
        .spawn().unwrap();
    // Skips cleanly with a message when CODEX_SANDBOX=seatbelt
}
```

**Alternative (skip when network is disabled):**

```rust
#[tokio::test]
async fn test_live_api_connection() {
    skip_if_no_network!();
    let client = create_client().await.unwrap();
    // Skips when CODEX_SANDBOX_NETWORK_DISABLED=1
}
```
