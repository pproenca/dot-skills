---
title: Route PII to log-only targets and keep traces cardinality-safe
impact: MEDIUM
impactDescription: prevents PII from leaking into wider-access trace backends
tags: otel, privacy, tracing, targets
---

## Route PII to log-only targets and keep traces cardinality-safe

Traces and logs typically go to different backends with different privacy tiers — traces to a wider-access APM, logs to a restricted pipeline. Per-field redaction is fragile; Codex gates at the *target* level. Two sentinel tracing targets — `codex_otel.log_only` and `codex_otel.trace_safe` — are installed on the logger layer and trace layer via filter functions that route on `meta.target()`. Events under `log_only` (carrying `user.email`, `user.account_id`) silently vanish from the trace exporter.

**Incorrect (one target, per-field redaction after the fact):**

```rust
tracing::info!(
    user.email = metadata.account_email,
    user.account_id = metadata.account_id,
    conversation.id = %metadata.conversation_id,
    "conversation started"
);
// Downstream processor has to remember to drop account_email per span.
```

**Correct (target routing via two macros):**

```rust
// otel/src/events/shared.rs
macro_rules! log_event {
    ($self:expr, $($fields:tt)*) => {{
        tracing::event!(
            target: $crate::targets::OTEL_LOG_ONLY_TARGET,
            tracing::Level::INFO,
            $($fields)*
            event.timestamp = %$crate::events::shared::timestamp(),
            conversation.id = %$self.metadata.conversation_id,
            user.account_id = $self.metadata.account_id,
            user.email = $self.metadata.account_email,
            model = %$self.metadata.model,
        );
    }};
}
// trace_event! — same expansion, but drops account_id / email.

// otel/src/provider.rs — filter functions on each layer
pub fn log_export_filter(meta: &tracing::Metadata<'_>) -> bool {
    is_log_export_target(meta.target())
}
pub fn trace_export_filter(meta: &tracing::Metadata<'_>) -> bool {
    meta.is_span() || is_trace_safe_target(meta.target())
}
```

The `log_and_trace_event!` composite macro forces callers to explicitly classify extra fields as `log:`-only, `trace:`-only, or `common:`. Sensitive shapes go to `log:`; their cardinality-bounded counterparts (counts, booleans) go to `trace:`. Even the auth env fingerprint is a boolean, never the key itself.

Reference: `codex-rs/otel/src/events/shared.rs:1`, `codex-rs/otel/src/provider.rs:150`.
