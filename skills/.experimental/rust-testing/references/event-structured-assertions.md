---
title: Use Structured Payload Assertions
impact: MEDIUM-HIGH
impactDescription: 3-5x more resilient assertions via parsed JSON vs raw strings
tags: event, structured-assertions, json, payload
---

## Use Structured Payload Assertions

Assert on parsed, structured data rather than raw string content of JSON payloads. String matching breaks when field ordering changes, whitespace varies, or new fields are added. Parse the body into `serde_json::Value` or use typed deserialization, then assert on specific fields.

**Incorrect (string matching is brittle to formatting changes):**

```rust
#[tokio::test]
async fn test_request_includes_model() {
    let request = mock.single_request();
    let body_str = String::from_utf8(request.body_bytes()).unwrap();
    assert!(body_str.contains("\"model\":\"gpt-4\""));
    // Breaks if serialization adds a space: "model": "gpt-4"
}
```

**Correct (structured assertion on parsed JSON):**

```rust
#[tokio::test]
async fn test_request_includes_model() {
    let request = mock.single_request();
    let body = request.body_json();
    assert_eq!(body["model"], "gpt-4");
    // Unaffected by whitespace, field ordering, or new fields
}
```
