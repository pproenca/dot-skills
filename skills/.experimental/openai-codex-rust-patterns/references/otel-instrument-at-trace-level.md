---
title: Default instrument spans to trace level, reserve info for network calls
impact: MEDIUM
impactDescription: enables free internal instrumentation that costs zero in normal operation
tags: otel, tracing, spans, performance
---

## Default instrument spans to trace level, reserve info for network calls

Sprinkling `info_span!` or `#[instrument]` at default level on every helper drowns stderr at INFO and pays the formatting cost for every call. Codex uses `level = "trace"` for almost all internal `#[instrument]` attributes (tool dispatch, turn sampling, parallel execution). Only functions that *actually issue a network request* are tagged `level = "info"`. Since the default subscriber filter is `codex_core=info`, internal spans cost zero at runtime — the subscriber evaluates the static metadata and returns before formatting any arguments.

**Incorrect (default-level instrument drowns stderr):**

```rust
#[instrument] // defaults to INFO — fires on every tool dispatch
async fn dispatch_tool_call(
    call: ToolCall,
    turn: &TurnContext,
) -> ToolResult { /* ... */ }
// Stderr floods with "dispatch_tool_call" records in normal operation.
```

**Correct (trace default, info for network boundary, skip_all):**

```rust
// core/src/codex.rs — internal code path
#[instrument(
    level = "trace",
    skip_all,
    fields(
        turn_id = %turn_context.sub_id,
        model = %turn_context.model_info.slug,
        cwd = %turn_context.cwd.display(),
    ),
)]
async fn run_sampling_request(
    /* ... */
) -> CodexResult<SamplingRequestResult> { /* ... */ }

// core/src/client.rs — network boundary gets INFO
#[instrument(
    name = "model_client.websocket_connection",
    level = "info",
    skip_all,
    fields(
        provider = %self.client.state.provider.name,
        wire_api = %self.client.state.provider.wire_api,
        transport = "responses_websocket",
        api.path = "responses",
        turn.has_metadata_header = params.turn_metadata_header.is_some(),
    ),
)]
async fn websocket_connection(
    &mut self,
    params: WebsocketConnectParams<'_>,
) -> WebsocketResult { /* ... */ }

// core/src/tools/router.rs
#[instrument(level = "trace", skip_all, err)]
pub async fn build_tool_call(/* ... */) -> ToolResult { /* ... */ }
```

The `err` argument is the idiomatic shortcut for "if this function returns `Err`, record it on the span automatically" — no manual error logging. Fields use `%` (Display) not `?` (Debug) for paths and ids, because Display is bounded where Debug can explode. `turn.has_metadata_header = ... .is_some()` is a booleanization pattern — the field is always present with cardinality 2, never the raw header value.

Reference: `codex-rs/core/src/client.rs:1040`, `codex-rs/core/src/codex.rs:6752`.
