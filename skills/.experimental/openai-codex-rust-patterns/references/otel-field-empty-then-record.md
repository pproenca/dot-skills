---
title: Declare span fields as field Empty then record when known
impact: MEDIUM
impactDescription: reduces duplicate child spans by keeping one parent span renamed at the apm
tags: otel, tracing, spans, dynamic-fields
---

## Declare span fields as field Empty then record when known

`#[instrument]` captures field values at entry, but the span's "true name" is often only known several statements later — after peeking at the next SSE event, or after dispatching a tool call by name. Spawning a new child span duplicates the parent's fields and loses start-to-first-byte timing on the original. Codex declares identifying fields as `field::Empty` up front, then calls `span.record("field_name", value)` once the fact is known. OpenTelemetry has a special field, `otel.name`, which `tracing-opentelemetry` uses to override the span name at export.

**Incorrect (spawn a new child span once the identity is known):**

```rust
let parent = trace_span!("receiving_stream");
let event = stream.next().await?;
// Lose parent's timing; duplicate fields on child
let child = trace_span!(parent: &parent, "tool_call", tool_name = ?event.tool);
```

**Correct (Empty placeholder, record when facts arrive):**

```rust
// core/src/codex.rs
let receiving_span = trace_span!("receiving_stream");
let handle_responses = trace_span!(
    parent: &receiving_span,
    "handle_responses",
    otel.name = field::Empty,
    tool_name = field::Empty,
    from = field::Empty,
);

// otel/src/events/session_telemetry.rs
pub fn record_responses(
    &self,
    handle_responses_span: &Span,
    event: &ResponseEvent,
) {
    handle_responses_span.record(
        "otel.name",
        SessionTelemetry::responses_type(event),
    );
    match event {
        ResponseEvent::OutputItemDone(item) => {
            handle_responses_span.record("from", "output_item_done");
            if let ResponseItem::FunctionCall { name, .. } = item {
                handle_responses_span.record("tool_name", name.as_str());
            }
        }
        /* ... */
    }
}

// core/src/tools/parallel.rs — default field + record-on-change
let dispatch_span = trace_span!(
    "dispatch_tool_call",
    otel.name = display_name.as_str(),
    tool_name = display_name.as_str(),
    call_id = call.call_id.as_str(),
    aborted = false,
);
// ... later, inside tokio::select! on cancel:
dispatch_span.record("aborted", true);
```

`field::Empty` is load-bearing — tracing-subscriber will not emit the field if `record` is never called, so empty placeholders reserve schema slots without producing null-like noise. The `aborted = false` default plus a single `record("aborted", true)` on cancel is how Codex tracks abort rates without a counter.

Reference: `codex-rs/core/src/codex.rs:7593`, `codex-rs/otel/src/events/session_telemetry.rs:292`.
