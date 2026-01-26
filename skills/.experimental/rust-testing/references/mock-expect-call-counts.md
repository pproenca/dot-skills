---
title: Verify Mock Call Counts Explicitly
impact: HIGH
impactDescription: catches missing or duplicate calls
tags: mock, mockall, expectations, verification
---

## Verify Mock Call Counts Explicitly

Use `times()` to verify mocks are called the expected number of times. Unchecked mocks can hide bugs where methods are called too many or too few times.

**Incorrect (no call count verification):**

```rust
#[test]
fn process_order_sends_notification() {
    let mut mock_notifier = MockNotifier::new();

    mock_notifier.expect_send()
        .returning(|_| Ok(()));  // No times() - called any number of times

    let service = OrderService::new(mock_notifier);
    service.process_order(order).unwrap();
    // Bug: send() might be called twice, or not at all - test still passes!
}
```

**Correct (explicit call count verification):**

```rust
#[test]
fn process_order_sends_exactly_one_notification() {
    let mut mock_notifier = MockNotifier::new();

    mock_notifier.expect_send()
        .times(1)  // Fails if called 0 or 2+ times
        .returning(|_| Ok(()));

    let service = OrderService::new(mock_notifier);
    service.process_order(order).unwrap();
}

#[test]
fn batch_process_sends_notification_per_order() {
    let mut mock_notifier = MockNotifier::new();

    mock_notifier.expect_send()
        .times(3)  // Exactly 3 calls expected
        .returning(|_| Ok(()));

    let service = OrderService::new(mock_notifier);
    service.process_batch(&[order1, order2, order3]).unwrap();
}

#[test]
fn cancelled_order_does_not_notify() {
    let mut mock_notifier = MockNotifier::new();

    mock_notifier.expect_send()
        .times(0);  // Explicitly verify no calls

    let mut order = create_order();
    order.cancel();

    let service = OrderService::new(mock_notifier);
    service.process_order(order).unwrap();
}
```

**Call count options:**

```rust
.times(1)                    // Exactly 1
.times(0)                    // Never called
.times(2..5)                 // 2, 3, or 4 times
.times(..)                   // Any number (default, avoid this)
.times(mockall::Sequence)    // Verify call order
```

**Verify call order:**

```rust
#[test]
fn operations_happen_in_order() {
    let mut mock = MockDatabase::new();
    let mut seq = mockall::Sequence::new();

    mock.expect_begin_transaction()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|| Ok(()));

    mock.expect_insert()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|_| Ok(()));

    mock.expect_commit()
        .times(1)
        .in_sequence(&mut seq)
        .returning(|| Ok(()));
}
```

Reference: [mockall - Expectations](https://docs.rs/mockall/latest/mockall/#expectations)
