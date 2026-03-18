---
title: Use TempDir for Filesystem Test Isolation
impact: CRITICAL
impactDescription: eliminates cross-test filesystem pollution in 100% of IO tests
tags: arch, tempdir, isolation, filesystem
---

## Use TempDir for Filesystem Test Isolation

Tests that read or write files must use `tempfile::TempDir` for hermetic isolation. The helper `load_default_config_for_test(codex_home)` confines all on-disk state to a per-test temporary directory, preventing tests from clobbering each other or a developer's real `~/.codex`.

**Incorrect (tests share a hardcoded path):**

```rust
#[tokio::test]
async fn test_config_persistence() {
    let config_path = PathBuf::from("/tmp/test-config.toml");
    std::fs::write(&config_path, "model = \"gpt-4\"").unwrap();
    let config = Config::load(&config_path).await.unwrap();
    assert_eq!(config.model, Some("gpt-4".into()));
    // Other tests using /tmp/test-config.toml will collide
}
```

**Correct (TempDir provides per-test isolation):**

```rust
#[tokio::test]
async fn test_config_persistence() {
    let codex_home = TempDir::new().expect("create temp dir");
    let config_path = codex_home.path().join("config.toml");
    std::fs::write(&config_path, "model = \"gpt-4\"").unwrap();
    let config = load_default_config_for_test(&codex_home).await;
    assert_eq!(config.model, Some("gpt-4".into()));
    // TempDir is cleaned up when dropped, no cross-test pollution
}
```
