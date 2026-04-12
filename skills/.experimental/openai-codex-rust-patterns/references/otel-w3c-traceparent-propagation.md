---
title: Propagate W3C traceparent via env, RPC, and HTTP headers
impact: MEDIUM
impactDescription: enables distributed tracing from CI runner through codex to backend APIs
tags: otel, distributed-tracing, propagation, correlation
---

## Propagate W3C traceparent via env, RPC, and HTTP headers

When Codex is one hop in a distributed trace — downstream of a CI system, upstream of an API server — each entry point needs to accept an incoming trace context and every outbound request needs to emit one. Codex funnels four entry points through the same `TraceContextPropagator`: `TRACEPARENT` env vars read once via `OnceLock`, typed `W3cTraceContext` fields inside JSON-RPC envelopes, `traceparent` headers on outbound HTTP, and `warn!` on invalid inbound contexts so nothing panics or fabricates a new root.

**Incorrect (home-grown request_id UUID in log lines):**

```rust
let request_id = Uuid::new_v4();
tracing::info!("request_id={request_id} starting turn");
// Correlating across services requires scraping logs.
```

**Correct (W3C traceparent in, W3C traceparent out, OnceLock env cache):**

```rust
// otel/src/trace_context.rs
pub fn traceparent_context_from_env() -> Option<Context> {
    TRACEPARENT_CONTEXT
        .get_or_init(load_traceparent_context)
        .clone()
}

fn load_traceparent_context() -> Option<Context> {
    let traceparent = env::var(TRACEPARENT_ENV_VAR).ok()?;
    let tracestate = env::var(TRACESTATE_ENV_VAR).ok();
    match context_from_trace_headers(
        Some(&traceparent),
        tracestate.as_deref(),
    ) {
        Some(context) => {
            debug!("continuing parent trace context");
            Some(context)
        }
        None => {
            warn!("TRACEPARENT is set but invalid; ignoring");
            None
        }
    }
}

pub fn span_w3c_trace_context(span: &Span) -> Option<W3cTraceContext> {
    let context = span.context();
    if !context.span().span_context().is_valid() {
        return None;
    }
    let mut headers = HashMap::new();
    TraceContextPropagator::new()
        .inject_context(&context, &mut headers);
    Some(W3cTraceContext {
        traceparent: headers.remove("traceparent"),
        tracestate: headers.remove("tracestate"),
    })
}
```

```rust
// app-server/src/app_server_tracing.rs — request > env > new root
fn attach_parent_context(
    span: &Span,
    method: &str,
    request_id: &impl std::fmt::Display,
    parent_trace: Option<&W3cTraceContext>,
) {
    if let Some(trace) = parent_trace {
        if !set_parent_from_w3c_trace_context(span, trace) {
            tracing::warn!(
                rpc_method = method,
                rpc_request_id = %request_id,
                "ignoring invalid inbound request trace carrier"
            );
        }
    } else if let Some(context) = traceparent_context_from_env() {
        set_parent_from_context(span, context);
    }
}
```

The env-var load is gated behind `OnceLock` because `TRACEPARENT` is set at process start — reading it every span creation would be wasteful. The fallback priority (request-provided > env > new root) is the inverse of what most codebases get wrong.

Reference: `codex-rs/otel/src/trace_context.rs:66`, `codex-rs/app-server/src/app_server_tracing.rs:124`.
