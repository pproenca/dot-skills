---
title: Use ResponseMock for Request Body Assertions
impact: HIGH
impactDescription: enables structured assertions on captured HTTP request payloads
tags: mock, response-mock, request-capture, assertions
---

## Use ResponseMock for Request Body Assertions

All `mount_sse*` helpers return a `ResponseMock` that captures every outbound `/responses` POST. Use `single_request()` when a test issues exactly one POST, or `requests()` to inspect all captured payloads. This eliminates manual wiremock request verification.

**Incorrect (no request body verification):**

```rust
#[tokio::test]
async fn test_function_call_output_sent() {
    let server = MockServer::start().await;
    responses::mount_sse_once(&server, sse_body).await;
    // Ignores the ResponseMock return value
    codex.submit(Op::UserTurn { content: "run ls".into() }).await.unwrap();
    // No way to verify what was sent to the mock server
}
```

**Correct (ResponseMock captures and verifies requests):**

```rust
#[tokio::test]
async fn test_function_call_output_sent() {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(&server, sse_body).await;
    codex.submit(Op::UserTurn { content: "run ls".into() }).await.unwrap();

    let request = mock.single_request();
    let body = request.body_json();
    assert!(body["input"].is_array());
    assert!(request.body_contains_text("ls"));
}
```
