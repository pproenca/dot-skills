---
title: Derive Default for Configuration Structs
impact: MEDIUM
impactDescription: enables struct update syntax, simplifies test setup
tags: api, default, derive, configuration, ergonomics
---

## Derive Default for Configuration Structs

Derive or implement `Default` for configuration and option structs. This enables `..Default::default()` struct update syntax, simplifies test setup, and makes it clear what the baseline values are.

**Incorrect (no Default, every field must be specified):**

```rust
#[derive(Debug, Clone)]
pub struct NetworkConfig {
    pub enabled: bool,
    pub proxy_url: String,
    pub timeout_ms: u64,
    pub max_retries: u32,
    pub allowed_domains: Vec<String>,
}
// Tests must specify all 5 fields even when testing one
```

**Correct (Default provides sensible baseline):**

```rust
#[derive(Debug, Clone, Default)]
pub struct NetworkConfig {
    pub enabled: bool,
    pub proxy_url: String,
    pub timeout_ms: u64,
    pub max_retries: u32,
    pub allowed_domains: Vec<String>,
}
// Test setup: NetworkConfig { enabled: true, ..Default::default() }
```
