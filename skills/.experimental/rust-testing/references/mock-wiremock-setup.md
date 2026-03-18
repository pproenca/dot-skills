---
title: Use wiremock MockServer for HTTP Testing
impact: HIGH
impactDescription: eliminates network dependency in 100% of integration tests
tags: mock, wiremock, http, mock-server
---

## Use wiremock MockServer for HTTP Testing

Use `wiremock::MockServer` to create local HTTP mock servers for all tests that interact with external APIs. Each test gets its own server instance on a random port, ensuring complete isolation. The `core_test_support::responses` module provides pre-built helpers that wrap wiremock setup.

**Incorrect (hardcoded URL or shared mock server):**

```rust
#[tokio::test]
async fn test_api_call() {
    // Depends on external server being available
    let client = Client::new("https://api.openai.com");
    let response = client.create_response("hello").await.unwrap();
    assert!(response.status().is_success());
}
```

**Correct (per-test wiremock MockServer):**

```rust
#[tokio::test]
async fn test_api_call() {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(
        &server,
        responses::sse(vec![
            responses::ev_response_created("resp-1"),
            responses::ev_completed("resp-1"),
        ]),
    ).await;

    let mut codex = TestCodexBuilder::new()
        .build(&server).await.unwrap();
    codex.submit(Op::UserTurn { content: "hello".into() }).await.unwrap();
    let request = mock.single_request();
    assert!(request.body_json()["input"].is_array());
}
```
