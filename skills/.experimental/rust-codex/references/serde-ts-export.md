---
title: Align serde and ts-rs Annotations
impact: HIGH
impactDescription: prevents Rust/TypeScript serialization mismatches
tags: serde, ts-rs, typescript, wire-format
---

## Align serde and ts-rs Annotations

When a field or variant uses `#[serde(rename = "...")]`, add a matching `#[ts(rename = "...")]`. When a struct uses `#[serde(rename_all = "camelCase")]`, add `#[ts(rename_all = "camelCase")]`. Always set `#[ts(export_to = "v2/")]` on v2 types so generated TypeScript lands in the correct namespace.

**Incorrect (serde and ts annotations diverge):**

```rust
#[derive(Serialize, Deserialize, TS)]
#[serde(rename_all = "camelCase")]
pub struct ConfigWriteResponse {
    pub config_path: String,
    #[serde(rename = "didChange")]
    pub changed: bool,
}
// Rust serializes "didChange", TS type expects "changed"
```

**Correct (annotations aligned across both serializers):**

```rust
#[derive(Serialize, Deserialize, TS)]
#[serde(rename_all = "camelCase")]
#[ts(rename_all = "camelCase")]
#[ts(export_to = "v2/")]
pub struct ConfigWriteResponse {
    pub config_path: String,
    #[serde(rename = "didChange")]
    #[ts(rename = "didChange")]
    pub changed: bool,
}
// Both Rust wire and TS type use "didChange"
```
