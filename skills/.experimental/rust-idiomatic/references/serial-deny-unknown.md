---
title: Use deny_unknown_fields for Strict Deserialization
impact: MEDIUM
impactDescription: catches 100% of field typos at parse time vs silent data loss
tags: serial, deny-unknown-fields, serde, validation, strict
---

## Use deny_unknown_fields for Strict Deserialization

Apply `#[serde(deny_unknown_fields)]` to types where unexpected fields indicate a bug (typo, version mismatch, wrong payload). Without it, serde silently ignores unknown fields, masking configuration errors.

**Incorrect (typo silently ignored):**

```rust
#[derive(Deserialize)]
pub struct PlanToolCall {
    pub title: String,
    pub command: Vec<String>,
}
// {"titel": "deploy", "command": ["cargo", "build"]}
// Deserializes with title="" — typo silently lost
```

**Correct (typo caught at parse time):**

```rust
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PlanToolCall {
    pub title: String,
    pub command: Vec<String>,
}
// {"titel": "deploy"} => Error: unknown field `titel`
```

**When NOT to use this pattern:**

- On types that use `#[serde(flatten)]`, which is incompatible with `deny_unknown_fields`
- On types designed for forward compatibility where unknown fields should be preserved
