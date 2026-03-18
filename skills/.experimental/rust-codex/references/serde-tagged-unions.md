---
title: Use Explicit Tag for Discriminated Unions
impact: HIGH
impactDescription: prevents 100% of union deserialization failures across Rust/TS
tags: serde, tagged-unions, discriminated-unions, enums
---

## Use Explicit Tag for Discriminated Unions

For discriminated unions, use explicit tagging in both serde and ts-rs: `#[serde(tag = "type", ...)]` and `#[ts(tag = "type", ...)]`. Without explicit tags, serde defaults to externally-tagged representation which produces `{"VariantName": {...}}` instead of the `{"type": "variantName", ...}` format TypeScript expects.

**Incorrect (implicit external tagging):**

```rust
#[derive(Serialize, Deserialize, TS)]
pub enum LoginAccountParams {
    Chatgpt(ChatgptLoginParams),
    ApiKey(ApiKeyLoginParams),
}
// Wire: {"Chatgpt": {"redirect_url": "..."}}
```

**Correct (explicit internal tag in both serializers):**

```rust
#[derive(Serialize, Deserialize, TS)]
#[serde(tag = "type", rename_all = "camelCase")]
#[ts(tag = "type", rename_all = "camelCase")]
#[ts(export_to = "v2/")]
pub enum LoginAccountParams {
    Chatgpt(ChatgptLoginParams),
    ApiKey(ApiKeyLoginParams),
}
// Wire: {"type": "chatgpt", "redirectUrl": "..."}
```
