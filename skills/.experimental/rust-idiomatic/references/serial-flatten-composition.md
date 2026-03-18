---
title: Use serde flatten for Struct Composition
impact: MEDIUM
impactDescription: enables composable config types without nesting in wire format
tags: serial, flatten, serde, composition, config
---

## Use serde flatten for Struct Composition

Use `#[serde(flatten)]` to embed one struct's fields directly into another's serialized representation. This enables composition of config types while keeping the wire format flat and the Rust types modular.

**Incorrect (nested struct creates extra JSON level):**

```rust
#[derive(Serialize, Deserialize)]
pub struct PermissionsToml {
    pub entries: BTreeMap<String, PermissionProfile>,
}
// Wire: {"entries": {"default": {...}}}
// Users must write [permissions.entries.default]
```

**Correct (flatten inlines the map at the parent level):**

```rust
#[derive(Serialize, Deserialize)]
pub struct PermissionsToml {
    #[serde(flatten)]
    pub entries: BTreeMap<String, PermissionProfile>,
}
// Wire: {"default": {...}}
// Users write [permissions.default] directly
```

**Warning (flatten and deny_unknown_fields conflict):**

`#[serde(flatten)]` and `#[serde(deny_unknown_fields)]` cannot be used on the same struct. If you need strict validation, add it as a post-deserialization check.
