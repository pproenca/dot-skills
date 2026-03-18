---
title: Build SSE Payloads with ev_ Constructors
impact: HIGH
impactDescription: 10-20x reduction in SSE payload construction code
tags: mock, sse, ev-constructors, payload-builders
---

## Build SSE Payloads with ev_ Constructors

Build SSE response payloads using the provided `ev_*` constructor functions (`ev_response_created`, `ev_function_call`, `ev_completed`, `ev_assistant_message`, etc.) and wrap them with `sse(...)`. These constructors produce correctly structured JSON that matches the real OpenAI responses API format.

**Incorrect (hand-crafted SSE JSON prone to format errors):**

```rust
let sse_body = format!(
    "event: response.created\ndata: {{\"type\":\"response.created\",\"response\":{{\"id\":\"{id}\"}}}}\n\n\
     event: response.completed\ndata: {{\"type\":\"response.completed\",\"response\":{{\"id\":\"{id}\"}}}}\n\n",
    id = "resp-1"
);
```

**Correct (ev_ constructors ensure correct SSE format):**

```rust
let sse_body = responses::sse(vec![
    responses::ev_response_created("resp-1"),
    responses::ev_function_call("call-1", "shell", &serde_json::to_string(&args)?),
    responses::ev_completed("resp-1"),
]);
```
