---
title: Avoid Test Dependency on Process Environment
impact: MEDIUM
impactDescription: prevents failures when tests run in CI, containers, or sandboxed environments
tags: det, environment, portability, ci
---

## Avoid Test Dependency on Process Environment

Tests must not depend on specific environment variables being set or absent. CI environments, containers, and developer machines have different environment configurations. Inject required values through test parameters or configuration objects.

**Incorrect (test depends on HOME being set):**

```rust
#[test]
fn test_config_file_location() {
    let home = std::env::var("HOME").unwrap();
    let config_path = PathBuf::from(home).join(".codex/config.toml");
    assert!(config_path.starts_with("/Users/") || config_path.starts_with("/home/"));
    // Fails in CI containers where HOME=/root or HOME is unset
}
```

**Correct (test provides its own base path):**

```rust
#[test]
fn test_config_file_location() {
    let codex_home = TempDir::new().unwrap();
    let config_path = codex_home.path().join("config.toml");
    assert!(config_path.parent().unwrap().exists());
    // Works in any environment
}
```
