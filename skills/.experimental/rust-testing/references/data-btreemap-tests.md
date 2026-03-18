---
title: Use BTreeMap in Tests for Deterministic Ordering
impact: HIGH
impactDescription: eliminates nondeterministic assertion failures from HashMap ordering
tags: data, btreemap, determinism, ordering
---

## Use BTreeMap in Tests for Deterministic Ordering

Use `BTreeMap` instead of `HashMap` in test code when the map contents are serialized or compared. `HashMap` iteration order is nondeterministic, causing flaky snapshot tests and intermittent `assert_eq!` failures. `BTreeMap` provides stable, sorted iteration order.

**Incorrect (HashMap ordering causes flaky assertions):**

```rust
#[test]
fn test_sandbox_config_serialization() {
    let mut entries = HashMap::new();
    entries.insert("read".to_string(), PathBuf::from("/usr"));
    entries.insert("exec".to_string(), PathBuf::from("/bin"));
    let config = SandboxConfig { entries };
    let json = serde_json::to_string(&config).unwrap();
    // json key order depends on HashMap internal state — flaky!
    assert_eq!(json, r#"{"entries":{"exec":"/bin","read":"/usr"}}"#);
}
```

**Correct (BTreeMap ensures stable serialization order):**

```rust
#[test]
fn test_sandbox_config_serialization() {
    let mut entries = BTreeMap::new();
    entries.insert("exec".to_string(), PathBuf::from("/bin"));
    entries.insert("read".to_string(), PathBuf::from("/usr"));
    let config = SandboxConfig { entries };
    let json = serde_json::to_string(&config).unwrap();
    // BTreeMap guarantees alphabetical key order — always stable
    assert_eq!(json, r#"{"entries":{"exec":"/bin","read":"/usr"}}"#);
}
```
