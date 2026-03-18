---
title: Prefer mount_sse_once for SSE Response Mocking
impact: HIGH
impactDescription: reduces SSE mock setup from 15+ lines to 3-5 lines
tags: mock, sse, mount-sse-once, responses
---

## Prefer mount_sse_once for SSE Response Mocking

Use `mount_sse_once` over `mount_sse_once_match` or `mount_sse_sequence` for single-response SSE mocking. The simpler variant handles the common case of one POST to `/responses` returning one SSE stream. Use `mount_sse_once_match` only when you need to match on specific request properties.

**Incorrect (manual wiremock Mock setup for SSE):**

```rust
#[tokio::test]
async fn test_shell_command_execution() {
    let server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path_regex("/responses"))
        .respond_with(ResponseTemplate::new(200)
            .set_body_string(build_sse_body())
            .insert_header("content-type", "text/event-stream"))
        .mount(&server)
        .await;
    // 10+ lines of boilerplate, no request capture
}
```

**Correct (mount_sse_once with automatic request capture):**

```rust
#[tokio::test]
async fn test_shell_command_execution() {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(
        &server,
        responses::sse(vec![
            responses::ev_response_created("resp-1"),
            responses::ev_function_call("call-1", "shell", &args_json),
            responses::ev_completed("resp-1"),
        ]),
    ).await;
    // mock.single_request() captures the outbound POST for assertions
}
```
