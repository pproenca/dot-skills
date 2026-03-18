---
title: Assert Function Call Output in Mock Tests
impact: MEDIUM-HIGH
impactDescription: 100% verification coverage of outbound tool call outputs
tags: event, function-call, output-assertion, tool-calls
---

## Assert Function Call Output in Mock Tests

After a mock server returns a function call event and the agent processes it, verify that the subsequent request contains the correct `function_call_output` with the matching `call_id`. This confirms the agent executed the tool and submitted the result back to the API.

**Incorrect (only verifying the event was received, not the output sent):**

```rust
#[tokio::test]
async fn test_shell_command_runs() {
    let mock = mount_shell_call(&server, "call-1", "echo hello").await;
    codex.submit(Op::UserTurn { content: "say hello".into() }).await?;
    wait_for_event(&codex, |ev| matches!(ev, EventMsg::TaskComplete { .. })).await;
    // Never checks that function_call_output was sent back to the API
}
```

**Correct (verifying the function call output was sent in the follow-up request):**

```rust
#[tokio::test]
async fn test_shell_command_runs() {
    let mock = responses::mount_sse_once(&server, responses::sse(vec![
        responses::ev_response_created("resp-1"),
        responses::ev_function_call("call-1", "shell", &args_json),
        responses::ev_completed("resp-1"),
    ])).await;

    responses::mount_sse_once(&server, responses::sse(vec![
        responses::ev_response_created("resp-2"),
        responses::ev_completed("resp-2"),
    ])).await;

    codex.submit(Op::UserTurn { content: "say hello".into() }).await?;
    wait_for_event(&codex, |ev| matches!(ev, EventMsg::TaskComplete { .. })).await;

    assert!(mock.function_call_output_text("call-1").is_some());
}
```
