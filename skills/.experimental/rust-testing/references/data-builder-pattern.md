---
title: Use Builder Functions for Complex Test Objects
impact: HIGH
impactDescription: reduces test setup from 30+ lines to 3-5 lines per test
tags: data, builder-pattern, test-setup, factory
---

## Use Builder Functions for Complex Test Objects

Use builder patterns like `TestCodexBuilder` for constructing complex test objects. Builders provide sensible defaults while allowing per-test customization through method chaining. This eliminates repeated boilerplate and makes tests focus on the scenario being tested.

**Incorrect (manual construction repeated in every test):**

```rust
#[tokio::test]
async fn test_model_override() {
    let codex_home = TempDir::new().unwrap();
    let config = ConfigBuilder::default()
        .codex_home(codex_home.path().to_path_buf())
        .harness_overrides(ConfigOverrides::default())
        .build().await.unwrap();
    let auth = CodexAuth::ApiKey("test-key".into());
    let providers = built_in_model_providers();
    let thread = CodexThread::new(config, auth, providers).await.unwrap();
    // 10+ lines of identical setup in every test
}
```

**Correct (builder encapsulates defaults, tests customize only what differs):**

```rust
#[tokio::test]
async fn test_model_override() {
    let server = MockServer::start().await;
    let mut codex = TestCodexBuilder::new()
        .with_model("gpt-4o")
        .build(&server).await.unwrap();
    // 3 lines: builder handles TempDir, Config, auth, providers
}
```
