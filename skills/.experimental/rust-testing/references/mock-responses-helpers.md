---
title: Use core_test_support responses Utilities
impact: HIGH
impactDescription: reduces mock setup from 20+ lines to 3-5 lines per test
tags: mock, core-test-support, responses, utilities
---

## Use core_test_support responses Utilities

Use the pre-built utilities in `core_test_support::responses` when writing end-to-end Codex tests. These helpers encapsulate wiremock configuration, SSE stream construction, and request capture into a small set of composable functions. Avoid reimplementing this infrastructure in individual tests.

**Incorrect (reimplementing mock infrastructure per test):**

```rust
#[tokio::test]
async fn test_agent_turn() {
    let server = MockServer::start().await;
    let body = format!(
        "event: response.created\ndata: {}\n\nevent: response.completed\ndata: {}\n\n",
        serde_json::json!({"type": "response.created", "response": {"id": "r1"}}),
        serde_json::json!({"type": "response.completed", "response": {"id": "r1"}}),
    );
    Mock::given(method("POST"))
        .and(path_regex("/responses"))
        .respond_with(ResponseTemplate::new(200)
            .set_body_string(body)
            .insert_header("content-type", "text/event-stream"))
        .mount(&server).await;
}
```

**Correct (composable response helpers):**

```rust
#[tokio::test]
async fn test_agent_turn() {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(
        &server,
        responses::sse(vec![
            responses::ev_response_created("r1"),
            responses::ev_completed("r1"),
        ]),
    ).await;
}
```
