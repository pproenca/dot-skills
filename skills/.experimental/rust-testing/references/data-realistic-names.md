---
title: Use Domain-Realistic Names in Test Data
impact: HIGH
impactDescription: 2-3x faster test comprehension from domain-specific identifiers
tags: data, naming, readability, documentation
---

## Use Domain-Realistic Names in Test Data

Use meaningful, domain-specific names in test data that reflect real usage. Names like `"resp-1"`, `"call-1"`, `"shell"` communicate the test intent. Avoid generic names like `"test"`, `"foo"`, `"bar"` that obscure what is being tested.

**Incorrect (generic names obscure test intent):**

```rust
#[tokio::test]
async fn test_function_call() {
    let sse = responses::sse(vec![
        responses::ev_response_created("abc"),
        responses::ev_function_call("xyz", "foo", "{}"),
        responses::ev_completed("abc"),
    ]);
    // "abc", "xyz", "foo" give no context about the scenario
}
```

**Correct (domain-realistic names document the scenario):**

```rust
#[tokio::test]
async fn test_shell_function_call() {
    let call_id = "call-1";
    let sse = responses::sse(vec![
        responses::ev_response_created("resp-1"),
        responses::ev_function_call(call_id, "shell", &serde_json::to_string(&args)?),
        responses::ev_completed("resp-1"),
    ]);
    // "resp-1", "call-1", "shell" clarify the test scenario
}
```
