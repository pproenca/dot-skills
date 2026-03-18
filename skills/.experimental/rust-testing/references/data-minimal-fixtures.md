---
title: Use Minimal Fixtures That Test One Thing
impact: HIGH
impactDescription: reduces test maintenance burden by 50% when data structures change
tags: data, fixtures, minimalism, maintainability
---

## Use Minimal Fixtures That Test One Thing

Each test fixture should contain only the data needed to exercise one specific behavior. Overloaded fixtures with many fields create fragile tests that break when unrelated fields change. Use `..Default::default()` to fill in fields that are irrelevant to the assertion.

**Incorrect (fixture specifies every field, brittle to unrelated changes):**

```rust
#[test]
fn test_model_name_resolution() {
    let config = Config {
        model: Some("gpt-4".into()),
        temperature: Some(0.7),
        max_tokens: Some(4096),
        sandbox_policy: SandboxPolicy::Allowlist,
        api_base: Some("https://api.openai.com".into()),
        timeout: Duration::from_secs(30),
        instructions: Some("Be helpful".into()),
    };
    assert_eq!(config.model, Some("gpt-4".into()));
    // Adding a new field to Config breaks this test
}
```

**Correct (minimal fixture tests only the relevant field):**

```rust
#[test]
fn test_model_name_resolution() {
    let config = Config {
        model: Some("gpt-4".into()),
        ..Default::default()
    };
    assert_eq!(config.model, Some("gpt-4".into()));
    // New fields use defaults, test remains stable
}
```
