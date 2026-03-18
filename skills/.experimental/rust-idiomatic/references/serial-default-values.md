---
title: Use serde default for Backward Compatibility
impact: MEDIUM
impactDescription: enables adding new fields without breaking existing serialized data
tags: serial, default, serde, backward-compatibility, evolution
---

## Use serde default for Backward Compatibility

Use `#[serde(default)]` on fields that were added after the initial release or that have a natural zero value. This ensures older serialized data (configs, API responses, stored state) deserializes correctly without the new field being present.

**Incorrect (adding a field breaks existing configs):**

```rust
#[derive(Deserialize)]
pub struct HookConfig {
    pub command: String,
    pub timeout_sec: u64,  // New field, no default
    pub run_on_fail: bool, // New field, no default
}
// Existing config without these fields: deserialization error
```

**Correct (new fields default gracefully):**

```rust
#[derive(Deserialize)]
pub struct HookConfig {
    pub command: String,
    #[serde(default)]
    pub timeout_sec: u64,
    #[serde(default)]
    pub run_on_fail: bool,
}
// Existing config: timeout_sec=0, run_on_fail=false
```

**Alternative (custom default value):**

```rust
#[derive(Deserialize)]
pub struct HookConfig {
    pub command: String,
    #[serde(default = "default_timeout")]
    pub timeout_sec: u64,
}

fn default_timeout() -> u64 { 30 }
```
