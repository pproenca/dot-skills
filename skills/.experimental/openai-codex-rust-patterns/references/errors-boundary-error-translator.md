---
title: Translate errors at the layer boundary in one function
impact: CRITICAL
impactDescription: eliminates reqwest error status inspection scattered across business logic
tags: errors, boundary, thiserror, layering
---

## Translate errors at the layer boundary in one function

When layers are transport → api → core → protocol, letting `?` bubble a `reqwest::Error` straight up to the retry loop forces every caller to re-parse HTTP status codes, headers, and JSON bodies — inconsistently. Codex centralizes the translation in one `map_api_error` function per boundary. This function is the only place that parses error-body JSON, pulls `cf-ray` and `x-request-id` headers, and invents protocol-level semantic variants like `ServerOverloaded` and `UsageLimitReached`.

**Incorrect (HTTP inspection scattered across business logic):**

```rust
// In three different files:
let resp = client.post(url).send().await?;
if resp.status() == StatusCode::SERVICE_UNAVAILABLE {
    return Err(CodexErr::ServerOverloaded);
}
// Meanwhile in another caller: forgets the overloaded check entirely.
```

**Correct (one function owns the translation):**

```rust
// codex-api/src/api_bridge.rs
pub fn map_api_error(err: ApiError) -> CodexErr {
    match err {
        ApiError::ContextWindowExceeded => CodexErr::ContextWindowExceeded,
        ApiError::QuotaExceeded => CodexErr::QuotaExceeded,
        ApiError::Retryable { message, delay } => CodexErr::Stream(message, delay),
        ApiError::Transport(transport) => match transport {
            TransportError::Http { status, body, .. } => {
                let body_text = body.unwrap_or_default();
                if status == http::StatusCode::SERVICE_UNAVAILABLE
                    && let Ok(value) = serde_json::from_str::<serde_json::Value>(&body_text)
                    && matches!(
                        value.get("error").and_then(|e| e.get("code"))
                            .and_then(serde_json::Value::as_str),
                        Some("server_is_overloaded" | "slow_down")
                    )
                {
                    return CodexErr::ServerOverloaded;
                }
                /* other status-specific conversions */
                CodexErr::UnexpectedStatus(status)
            }
            /* transport-level errors */
        },
    }
}
```

The layer below returns a flat `TransportError::Http { status, headers, body }` and knows nothing about product semantics. The layer above never talks HTTP. Refactoring the reqwest client is now local — nothing above the boundary cares.

Reference: `codex-rs/codex-api/src/api_bridge.rs:18`.
