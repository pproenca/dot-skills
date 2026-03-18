---
title: Construct Test Data as Typed Structs Not JSON
impact: HIGH
impactDescription: 100% compile-time detection of field renames vs 0% with JSON
tags: data, typed-construction, compile-safety, structs
---

## Construct Test Data as Typed Structs Not JSON

Build expected test data using Rust structs with typed fields rather than `serde_json::json!()` values. When a struct field is renamed or its type changes, the compiler catches every affected test at build time. JSON-based test data fails silently at runtime or passes when it should fail.

**Incorrect (JSON construction bypasses type checking):**

```rust
#[test]
fn test_event_serialization() {
    let expected = serde_json::json!({
        "type": "session.configured",
        "model": "gpt-4",
        "sandboxPolicy": "allowlist"
    });
    let actual = serde_json::to_value(&event).unwrap();
    assert_eq!(actual, expected);
    // If "sandboxPolicy" is renamed to "sandbox_policy", this still compiles
}
```

**Correct (typed struct construction catches refactors at compile time):**

```rust
#[test]
fn test_event_serialization() {
    let expected = SessionConfiguredEvent {
        model: "gpt-4".into(),
        sandbox_policy: SandboxPolicy::Allowlist,
        ..Default::default()
    };
    assert_eq!(event, expected);
    // Renaming sandbox_policy causes a compile error here
}
```
