---
title: Give libraries structured error enums — anyhow stays at the application edge
tags: flow, thiserror, anyhow, error-design
---

## Give libraries structured error enums — anyhow stays at the application edge

`anyhow::Result` (or `Box<dyn Error>`) in a library's public API is the "everything throws Exception" design: callers receive an opaque blob they can only log or string-match, so retry logic ends up as `err.to_string().contains("timed out")`. The split is by *who matches*: a library's callers need to distinguish failures, so it exports a `thiserror` enum with a variant per distinguishable outcome; an application's `main` mostly reports failures upward, so `anyhow` with `.context(...)` is the right tool there — and only there.

**Incorrect (a library API that can only be logged):**

```rust
// in crate `billing-client`
pub fn charge(card: &Card, amount: Cents) -> anyhow::Result<Receipt> { /* ... */ }
// caller: if e.to_string().contains("declined") { ... }  ← string matching
```

**Correct (variants callers can match and act on):**

```rust
// in crate `billing-client`
#[derive(Debug, thiserror::Error)]
pub enum ChargeError {
    #[error("card declined by issuer")]
    Declined { code: DeclineCode },
    #[error("gateway timed out, retry after {retry_after:?}")]
    Timeout { retry_after: Duration },
    #[error("transport failure")]
    Transport(#[from] reqwest::Error),
}

pub fn charge(card: &Card, amount: Cents) -> Result<Receipt, ChargeError> { /* ... */ }
```

Designing the variants themselves — transient vs permanent split, carrying the retry delay, translating at layer boundaries — is covered in depth by the `errors-` rules of the sibling `openai-codex-rust-patterns` skill; this rule is the flatten that gets a codebase from opaque errors to a shape where those apply.

Reference: [anyhow — crate docs (use anyhow in applications, a dedicated error type in libraries)](https://docs.rs/anyhow/latest/anyhow/)
