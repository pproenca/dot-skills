---
title: Use codex submit Op for Integration Tests
impact: MEDIUM-HIGH
impactDescription: 100% protocol path coverage from input to event emission
tags: event, submit-op, integration, protocol
---

## Use codex submit Op for Integration Tests

Drive integration tests by submitting `Op` variants through `codex.submit()` and asserting on the resulting events. This exercises the full agent protocol path: user input, API call, tool execution, and event emission. Avoid testing internal functions directly when an end-to-end path exists.

**Incorrect (testing internal function bypasses the protocol):**

```rust
#[tokio::test]
async fn test_shell_execution() {
    let result = execute_shell_command("echo hello").await.unwrap();
    assert_eq!(result.stdout, "hello\n");
    // Skips: input parsing, API dispatch, tool routing, event emission
}
```

**Correct (submit Op exercises the full protocol path):**

```rust
#[tokio::test]
async fn test_shell_execution() {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(&server, responses::sse(vec![
        responses::ev_response_created("resp-1"),
        responses::ev_function_call("call-1", "shell", &args_json),
        responses::ev_completed("resp-1"),
    ])).await;

    let mut codex = TestCodexBuilder::new().build(&server).await.unwrap();
    codex.submit(Op::UserTurn { content: "list files".into() }).await.unwrap();
    wait_for_event(&codex, |ev| matches!(ev, EventMsg::TaskComplete { .. })).await;
}
```
