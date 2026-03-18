---
title: Run just write-config-schema After Config Changes
impact: MEDIUM
impactDescription: prevents CI failure from stale config schema
tags: cfg, schema, config, ci
---

## Run just write-config-schema After Config Changes

When you change `ConfigToml` or any nested config types in `codex-rs/core`, run `just write-config-schema` to regenerate `codex-rs/core/config.schema.json`. CI validates that the checked-in schema matches the code. Forgetting this step causes CI to fail with a schema drift error.

**Incorrect (change config struct without updating schema):**

```rust
// codex-rs/core/src/config.rs
#[derive(Serialize, Deserialize, JsonSchema)]
pub struct ConfigToml {
    pub model: Option<String>,
    pub new_setting: Option<bool>,  // Added this field
}
// Forgot to run: just write-config-schema
// CI fails: config.schema.json is stale
```

**Correct (regenerate schema after config changes):**

```rust
// codex-rs/core/src/config.rs
#[derive(Serialize, Deserialize, JsonSchema)]
pub struct ConfigToml {
    pub model: Option<String>,
    pub new_setting: Option<bool>,  // Added this field
}

// Then run from codex-rs/:
// just write-config-schema
// Commit the updated config.schema.json alongside the code change
```
