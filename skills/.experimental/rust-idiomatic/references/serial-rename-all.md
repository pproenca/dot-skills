---
title: Use rename_all for Consistent Wire Format
impact: MEDIUM
impactDescription: eliminates field-by-field rename annotations, enforces naming convention
tags: serial, rename-all, serde, wire-format, naming
---

## Use rename_all for Consistent Wire Format

Apply `#[serde(rename_all = "camelCase")]` (or `"snake_case"`) at the struct/enum level to set the wire format naming convention uniformly. This eliminates per-field `#[serde(rename)]` annotations and prevents inconsistencies.

**Incorrect (per-field renames, easy to forget one):**

```rust
#[derive(Serialize, Deserialize)]
pub struct NetworkPolicyDecision {
    #[serde(rename = "requestUrl")]
    pub request_url: String,
    #[serde(rename = "resolvedIp")]
    pub resolved_ip: String,
    pub allowed: bool,  // Oops, forgot rename
}
```

**Correct (struct-level rename_all applies uniformly):**

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NetworkPolicyDecision {
    pub request_url: String,
    pub resolved_ip: String,
    pub allowed: bool,
}
// Wire: {"requestUrl": "...", "resolvedIp": "...", "allowed": true}
```
