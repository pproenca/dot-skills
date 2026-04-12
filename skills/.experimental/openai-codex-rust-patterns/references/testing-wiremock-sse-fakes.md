---
title: Use wiremock and small SSE constructors instead of mocking HTTP traits
impact: MEDIUM-HIGH
impactDescription: enables serialization, retry, and streaming coverage on every test
tags: testing, fakes, async, wiremock
---

## Use wiremock and small SSE constructors instead of mocking HTTP traits

Defining `trait ModelClient` and mocking it with `mockall` bypasses serialization, retry logic, and the streaming parser entirely — which is exactly where the real bugs live. Codex spins up a real `wiremock::MockServer` on a random port, rewrites the config's `base_url` to point at it, and serves a canned Server-Sent-Events body assembled from small event constructor functions (`ev_response_created`, `ev_assistant_message`, `ev_function_call`, `ev_completed`) piped through a single `sse(Vec<Value>)` formatter. Tests then assert against the actual request captured by `ResponseMock::single_request()`.

**Incorrect (trait mock drifts from real wire format):**

```rust
#[mockall::automock]
trait ModelClient {
    async fn send_turn(&self, params: TurnParams) -> Result<Turn>;
}
// Passes local tests, fails in production when SSE parser bug lands.
```

**Correct (real HTTP server with SSE event constructors):**

```rust
// core/tests/common/responses.rs
pub fn sse(events: Vec<Value>) -> String {
    use std::fmt::Write as _;
    let mut out = String::new();
    for event in events {
        let kind = event.get("type")
            .and_then(|value| value.as_str())
            .unwrap();
        writeln!(&mut out, "event: {kind}").unwrap();
        write!(&mut out, "data: {event}\n\n").unwrap();
    }
    out
}

// core/src/codex_tests_guardian.rs
let _request_log = mount_sse_once(
    &server,
    sse(vec![
        ev_response_created("resp-guardian"),
        ev_assistant_message("msg-guardian", &json!({}).to_string()),
        ev_completed("resp-guardian"),
    ]),
).await;
```

`mount_sse_once` returns a `ResponseMock` handle; the same handle then lets the test assert what Codex actually *sent* — bidirectional coverage. Every test exercises the HTTP layer, serde, retry, and the SSE parser for free. No test in the codebase mocks a trait for the model client.

Reference: `codex-rs/core/tests/common/responses.rs:566`, `codex-rs/core/src/codex_tests_guardian.rs:49`.
