---
title: Avoid Mutating Process Environment in Tests
impact: CRITICAL
impactDescription: eliminates nondeterministic failures from shared global state
tags: arch, environment, isolation, determinism
---

## Avoid Mutating Process Environment in Tests

Calling `std::env::set_var` in tests mutates global process state that is shared across all test threads. This causes nondeterministic failures where tests pass individually but fail when run in parallel. Pass environment-derived flags or dependencies as function parameters instead.

**Incorrect (mutating shared process environment):**

```rust
#[test]
fn test_api_base_url_override() {
    std::env::set_var("CODEX_API_BASE", "http://localhost:8080");
    let url = resolve_api_base();
    assert_eq!(url, "http://localhost:8080");
    std::env::remove_var("CODEX_API_BASE"); // race condition with parallel tests
}
```

**Correct (passing configuration as a parameter):**

```rust
#[test]
fn test_api_base_url_override() {
    let overrides = ConfigOverrides {
        api_base: Some("http://localhost:8080".into()),
        ..ConfigOverrides::default()
    };
    let url = resolve_api_base_with_overrides(&overrides);
    assert_eq!(url, "http://localhost:8080");
}
```
