---
title: Remove @ObservedObject When Only Reading
impact: CRITICAL
impactDescription: eliminates spurious re-renders from unrelated property changes
tags: state, observed-object, observation, over-observation, refactoring
---

## Remove @ObservedObject When Only Reading

With ObservableObject (push-based observation), marking a dependency as @ObservedObject subscribes the view to every @Published property change on that object. If the view only reads one property, it still re-renders when any other property changes. When you only need a snapshot of a single value, pass that value directly as a parameter. This eliminates the observation subscription entirely and confines re-renders to views that actually need live updates. With @Observable (pull-based, iOS 17+), SwiftUI tracks only the properties each view reads, making this problem less common, but the principle still applies to ObservableObject codebases.

**Incorrect (observes entire object but reads only one property):**

```swift
class OrderViewModel: ObservableObject {
    @Published var items: [OrderItem] = []
    @Published var deliveryAddress: String = ""
    @Published var paymentMethod: String = ""
    @Published var orderTotal: Decimal = 0
}

struct OrderHeader: View {
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        // Re-renders when deliveryAddress, paymentMethod,
        // or items change, even though it only reads orderTotal
        Text("Total: \(viewModel.orderTotal, format: .currency(code: "USD"))")
    }
}
```

**Correct (receives only the value it needs, no observation overhead):**

```swift
class OrderViewModel: ObservableObject {
    @Published var items: [OrderItem] = []
    @Published var deliveryAddress: String = ""
    @Published var paymentMethod: String = ""
    @Published var orderTotal: Decimal = 0
}

struct OrderHeader: View {
    let orderTotal: Decimal

    var body: some View {
        // Only re-renders when parent passes a new orderTotal value
        Text("Total: \(orderTotal, format: .currency(code: "USD"))")
    }
}
```

Reference: [Comparing @Observable to ObservableObjects](https://www.donnywals.com/comparing-observable-to-observableobjects/)
