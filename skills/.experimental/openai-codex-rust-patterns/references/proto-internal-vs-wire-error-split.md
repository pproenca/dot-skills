---
title: Split internal error enums from wire error enums
impact: HIGH
impactDescription: enables internal error refactors without breaking the stable wire contract
tags: proto, errors, api-design, versioning
---

## Split internal error enums from wire error enums

A single `pub enum ProtocolError` that doubles as both internal type and wire type freezes refactoring — every internal change risks breaking year-old clients. Codex keeps them separate: `CodexErr` is the internal `thiserror` enum with 30+ variants, `From` conversions from `io::Error` and `serde_json::Error`, and `.downcast_ref()` helpers. `CodexErrorInfo` is the wire type — ~15 variants, every "connection failed" shape carries `http_status_code: Option<u16>`. A translator `to_codex_protocol_error()` maps one to the other and picks up the HTTP status from whichever variant carries it.

**Incorrect (single enum doubles as internal + wire):**

```rust
#[derive(Serialize, Deserialize, thiserror::Error)]
pub enum ProtocolError {
    // Refactoring internal shape breaks wire clients.
    Io(#[from] std::io::Error), // serde panics on this boundary anyway
    Stream(String),
}
```

**Correct (internal enum + wire enum + translator):**

```rust
// protocol/src/error.rs — internal, rich
impl CodexErr {
    pub fn to_codex_protocol_error(&self) -> CodexErrorInfo {
        match self {
            CodexErr::ContextWindowExceeded => {
                CodexErrorInfo::ContextWindowExceeded
            }
            CodexErr::UsageLimitReached(_)
            | CodexErr::QuotaExceeded
            | CodexErr::UsageNotIncluded => {
                CodexErrorInfo::UsageLimitExceeded
            }
            CodexErr::ServerOverloaded => CodexErrorInfo::ServerOverloaded,
            CodexErr::RetryLimit(_) => {
                CodexErrorInfo::ResponseTooManyFailedAttempts {
                    http_status_code: self.http_status_code_value(),
                }
            }
            CodexErr::ConnectionFailed(_) => {
                CodexErrorInfo::HttpConnectionFailed {
                    http_status_code: self.http_status_code_value(),
                }
            }
            /* ... */
        }
    }
}

// app-server-protocol/src/protocol/v2.rs — wire, frozen shape
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, JsonSchema, TS)]
#[serde(rename_all = "camelCase")]
pub enum CodexErrorInfo {
    ContextWindowExceeded,
    UsageLimitExceeded,
    HttpConnectionFailed {
        #[serde(rename = "httpStatusCode")]
        http_status_code: Option<u16>,
    },
    /* ~15 variants, every one additive */
}
```

You can refactor `CodexErr` freely (add fields, reshape tuples, swap underlying libraries) and only the translator cares — the wire protocol stays frozen. The two types never share a derive chain; there is no `From` conversion between them, only the explicit `to_codex_protocol_error()` method.

Reference: `codex-rs/protocol/src/error.rs:213`, `codex-rs/app-server-protocol/src/protocol/v2.rs:147`.
