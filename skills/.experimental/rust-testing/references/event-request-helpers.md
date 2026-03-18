---
title: Use ResponsesRequest Helpers for Body Assertions
impact: MEDIUM-HIGH
impactDescription: 5-10x less assertion code with typed helper methods
tags: event, responses-request, helpers, body-assertions
---

## Use ResponsesRequest Helpers for Body Assertions

`ResponsesRequest` exposes typed helper methods (`body_json`, `input`, `function_call_output`, `custom_tool_call_output`, `call_output`, `header`, `path`, `query_param`) that extract structured data from captured requests. Use these instead of manually traversing JSON paths.

**Incorrect (manual JSON path traversal is fragile):**

```rust
#[tokio::test]
async fn test_function_call_output_in_request() {
    let request = mock.single_request();
    let body: Value = serde_json::from_slice(&request.body_bytes()).unwrap();
    let input = body["input"].as_array().unwrap();
    let output_item = input.iter().find(|item| {
        item["type"] == "function_call_output"
            && item["call_id"] == "call-1"
    }).unwrap();
    let output_text = output_item["output"].as_str().unwrap();
    assert!(output_text.contains("success"));
}
```

**Correct (typed helpers extract structured data directly):**

```rust
#[tokio::test]
async fn test_function_call_output_in_request() {
    let request = mock.single_request();
    let output = request.function_call_output("call-1")
        .expect("function_call_output for call-1");
    assert!(output.contains("success"));
}
```
