---
title: Write a manual Debug impl that elides credentials instead of deriving it
impact: HIGH
impactDescription: stops tokens and credential providers leaking into {:?} and tracing output
tags: secrets, debug, logging, redaction
---

## Write a manual Debug impl that elides credentials instead of deriving it

`#[derive(Debug)]` is the reflexive choice, but on any struct that holds a token, credential provider, or auth header it is a latent leak: a single `tracing::debug!(?ctx)` or `{:?}` interpolation dumps the secret into logs that get shipped to a telemetry backend. Codex implements `Debug` by hand on credential-bearing types, printing only the safe fields and ending with `finish_non_exhaustive()` so the omission is visible and new fields don't silently start leaking.

**Incorrect (derive leaks the provider into every log line):**

```rust
#[derive(Clone, Debug)] // {:?} now prints the credentials provider
pub struct AwsAuthContext {
    credentials_provider: SharedCredentialsProvider,
    region: String,
    service: String,
}
```

**Correct (manual Debug, secret field omitted):**

```rust
// aws-auth/src/lib.rs
impl std::fmt::Debug for AwsAuthContext {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AwsAuthContext")
            .field("region", &self.region)
            .field("service", &self.service)
            .finish_non_exhaustive() // trailing `..` marks the elided credential
    }
}
```

`finish_non_exhaustive()` is the key choice over `finish()`: it documents that fields were deliberately dropped, and because the secret field is never named, adding another secret field later can't accidentally re-expose it through this impl. The same convention recurs wherever a credential is stored (`backend-client`, `login`, `realtime-webrtc`).

Reference: `codex-rs/aws-auth/src/lib.rs:70`.
