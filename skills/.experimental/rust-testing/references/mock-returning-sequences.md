---
title: Use Sequences for Multiple Return Values
impact: MEDIUM
impactDescription: enables testing retry logic and state changes
tags: mock, mockall, sequences, state-transitions
---

## Use Sequences for Multiple Return Values

Use `returning_st()` with mutable state or multiple `expect_*` calls to return different values on successive calls. This enables testing retry logic, pagination, and state changes.

**Incorrect (same return value every time):**

```rust
#[test]
fn retry_on_failure() {
    let mut mock_client = MockHttpClient::new();

    mock_client.expect_get()
        .returning(|_| Err(Error::Timeout));  // Always fails

    let service = ResilientService::new(mock_client);
    // Cannot test successful retry - mock always returns error
}
```

**Correct (different return values per call):**

```rust
#[test]
fn retries_then_succeeds() {
    let mut mock_client = MockHttpClient::new();
    let mut seq = mockall::Sequence::new();

    // First call: timeout
    mock_client.expect_get()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Err(Error::Timeout));

    // Second call: timeout
    mock_client.expect_get()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Err(Error::Timeout));

    // Third call: success
    mock_client.expect_get()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Ok(Response::new("success")));

    let service = ResilientService::new(mock_client);
    let result = service.fetch_with_retry("/api/data").unwrap();
    assert_eq!(result.body, "success");
}

#[test]
fn pagination_fetches_all_pages() {
    let mut mock_client = MockHttpClient::new();
    let mut seq = mockall::Sequence::new();

    // Page 1
    mock_client.expect_get()
        .with(eq("/items?page=1"))
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Ok(Response::json(r#"{"items": [1,2], "next": 2}"#)));

    // Page 2
    mock_client.expect_get()
        .with(eq("/items?page=2"))
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Ok(Response::json(r#"{"items": [3,4], "next": null}"#)));

    let service = PaginatedFetcher::new(mock_client);
    let all_items = service.fetch_all("/items").unwrap();
    assert_eq!(all_items, vec![1, 2, 3, 4]);
}
```

**Alternative: mutable counter:**

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

#[test]
fn returns_different_values() {
    let mut mock = MockDatabase::new();
    let call_count = AtomicUsize::new(0);

    mock.expect_get_value()
        .returning(move |_| {
            let count = call_count.fetch_add(1, Ordering::SeqCst);
            match count {
                0 => None,
                1 => Some(Value::new("cached")),
                _ => Some(Value::new("fresh")),
            }
        });
}
```

Reference: [mockall - Sequences](https://docs.rs/mockall/latest/mockall/#sequences)
