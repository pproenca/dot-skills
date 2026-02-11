---
title: "Inject Environment Dependencies for Tests"
impact: MEDIUM-HIGH
impactDescription: "eliminates singleton coupling in views"
tags: swiftui, environment, dependency-injection, testability
---

## Inject Environment Dependencies for Tests

Views that reach for shared singletons directly cannot be tested with substitute implementations, forcing every test to exercise real services. Accepting dependencies through SwiftUI's environment with a custom EnvironmentKey lets tests inject protocol-based fakes without modifying view code.

**Incorrect (singleton access makes substitution impossible):**

```swift
struct OrderSummaryView: View {
    let orderId: String

    var body: some View {
        AsyncContentView {
            let order = try await NetworkService.shared.fetchOrder(orderId) // singleton — tests hit real API
            OrderDetailCard(order: order)
        }
    }
}
```

**Correct (EnvironmentKey enables test substitution):**

```swift
protocol OrderFetching: Sendable {
    func fetchOrder(_ id: String) async throws -> Order
}

struct OrderServiceKey: EnvironmentKey {
    static let defaultValue: any OrderFetching = LiveOrderService()
}

extension EnvironmentValues {
    var orderService: any OrderFetching {
        get { self[OrderServiceKey.self] }
        set { self[OrderServiceKey.self] = newValue }
    }
}

struct OrderSummaryView: View {
    let orderId: String
    @Environment(\.orderService) private var orderService // injected via EnvironmentKey

    var body: some View {
        AsyncContentView {
            let order = try await orderService.fetchOrder(orderId)
            OrderDetailCard(order: order)
        }
    }
}

// In tests:
let mock = StubOrderService(stubbedOrder: Order.sample)
OrderSummaryView(orderId: "ORD-001")
    .environment(\.orderService, mock) // swap real service for deterministic fake
```
