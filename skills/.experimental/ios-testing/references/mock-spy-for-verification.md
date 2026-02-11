---
title: "Use Spies to Verify Interactions"
impact: HIGH
impactDescription: "reduces test brittleness by 50%+"
tags: mock, spy, verification, behavior-testing
---

## Use Spies to Verify Interactions

Testing only return values misses critical side effects like analytics events, navigation calls, or persistence writes. Spies record method calls and arguments so tests verify that the correct interactions happened with the correct data, without coupling to internal ordering or implementation details.

**Incorrect (only checks final state, misses whether analytics was called):**

```swift
func testCompletePurchase() async throws {
    let viewModel = PurchaseViewModel(
        paymentService: MockPaymentService(result: .success(.confirmed)),
        analytics: MockAnalytics()
    )

    await viewModel.completePurchase(itemId: "SKU-100", amount: 49_99)

    #expect(viewModel.state == .confirmed) // passes even if analytics.track() was never called
}
```

**Correct (spy records calls for precise behavior verification):**

```swift
final class SpyAnalytics: AnalyticsTracking {
    private(set) var trackedEvents: [(name: String, properties: [String: String])] = [] // records every call

    func track(event: String, properties: [String: String]) {
        trackedEvents.append((name: event, properties: properties))
    }
}

func testCompletePurchase() async throws {
    let spyAnalytics = SpyAnalytics()
    let viewModel = PurchaseViewModel(
        paymentService: MockPaymentService(result: .success(.confirmed)),
        analytics: spyAnalytics
    )

    await viewModel.completePurchase(itemId: "SKU-100", amount: 49_99)

    #expect(viewModel.state == .confirmed)
    #expect(spyAnalytics.trackedEvents.count == 1)
    #expect(spyAnalytics.trackedEvents.first?.name == "purchase_completed")
    #expect(spyAnalytics.trackedEvents.first?.properties["item_id"] == "SKU-100") // verifies exact argument
}
```
