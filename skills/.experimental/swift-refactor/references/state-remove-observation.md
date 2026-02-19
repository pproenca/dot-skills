---
title: Migrate @ObservedObject to @Observable Property-Level Tracking
impact: CRITICAL
impactDescription: eliminates O(N) broadcast re-renders — only views reading changed property update
tags: state, observed-object, observable, migration, over-observation
---

## Migrate @ObservedObject to @Observable Property-Level Tracking

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

With `ObservableObject`, marking a dependency as `@ObservedObject` subscribes the view to every `@Published` change — even properties it never reads. With `@Observable` (iOS 26 / Swift 6.2), SwiftUI automatically tracks which properties each view accesses and only re-renders when those specific properties change. Replace `@ObservedObject` with a plain property and let `@Observable` handle targeted tracking.

**Incorrect (@ObservedObject re-renders on every @Published change):**

```swift
class OrderViewModel: ObservableObject {
    @Published var items: [OrderItem] = []
    @Published var deliveryAddress: String = ""
    @Published var paymentMethod: String = ""
    @Published var orderTotal: Decimal = 0
}

struct OrderHeader: View {
    @ObservedObject var viewModel: OrderViewModel
    // Re-renders when deliveryAddress, paymentMethod, or items change
    // even though it only reads orderTotal

    var body: some View {
        Text("Total: \(viewModel.orderTotal, format: .currency(code: "USD"))")
    }
}
```

**Correct (@Observable — automatic property-level tracking):**

```swift
@Observable
class OrderViewModel {
    var items: [OrderItem] = []
    var deliveryAddress: String = ""
    var paymentMethod: String = ""

    var orderTotal: Decimal {
        items.reduce(0) { $0 + $1.price }
    }
}

struct OrderHeader: View {
    var viewModel: OrderViewModel
    // Only re-renders when orderTotal (computed from items) changes
    // Changes to deliveryAddress or paymentMethod are ignored

    var body: some View {
        Text("Total: \(viewModel.orderTotal, format: .currency(code: "USD"))")
    }
}
```

**Pass primitives for maximum isolation:**

```swift
struct OrderHeader: View {
    let orderTotal: Decimal
    // Zero observation — only re-renders when parent passes new value

    var body: some View {
        Text("Total: \(orderTotal, format: .currency(code: "USD"))")
    }
}
```

**Migration checklist:**
- `@ObservedObject var` → plain `var` (for injected @Observable)
- `@StateObject var` → `@State var` (for owned @Observable)
- Or pass individual properties instead of entire objects for maximum isolation

Reference: [Comparing @Observable to ObservableObjects](https://www.donnywals.com/comparing-observable-to-observableobjects/)
