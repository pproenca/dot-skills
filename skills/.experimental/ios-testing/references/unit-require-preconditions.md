---
title: "Use #require for Test Preconditions"
impact: HIGH
impactDescription: "prevents cascading nil errors across 10+ subsequent assertions"
tags: unit, require, preconditions, optionals, fail-fast
---

## Use #require for Test Preconditions

When a test depends on an optional value being non-nil, force-unwrapping crashes the entire test suite with no diagnostic context, and optional chaining silently skips assertions on nil. #require unwraps the value or immediately fails the single test with a message showing exactly which precondition was not met.

**Incorrect (force-unwrap crashes the runner, optional chaining hides bugs):**

```swift
@Test func displaysShippingEstimate() async {
    let store = OrderStore(client: MockOrderClient())
    await store.loadOrders(for: "customer-42")

    let firstOrder = store.orders.first! // fatal error if empty — kills entire test process
    let tracking = firstOrder.tracking
    #expect(tracking?.estimatedDelivery != nil) // silently passes if tracking is nil
    #expect(tracking?.carrier == "FedEx") // silently passes — nil != "FedEx" is false, but test does not fail
}
```

**Correct (unwrap-or-fail with a clear diagnostic):**

```swift
@Test func displaysShippingEstimate() async throws {
    let store = OrderStore(client: MockOrderClient())
    await store.loadOrders(for: "customer-42")

    let firstOrder = try #require(store.orders.first) // fails: "Expectation failed: store.orders.first is nil"
    let tracking = try #require(firstOrder.tracking) // fails fast here instead of cascading nil through assertions
    #expect(tracking.estimatedDelivery != nil)
    #expect(tracking.carrier == "FedEx")
}
```
