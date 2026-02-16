---
title: Use navigationDestination(item:) for Optional-Based Navigation (iOS 17+)
impact: MEDIUM-HIGH
impactDescription: eliminates manual nil-checking and boolean state for push navigation
tags: arch, navigation-destination, optional, ios17
---

## Use navigationDestination(item:) for Optional-Based Navigation (iOS 17+)

The `navigationDestination(item:destination:)` modifier (iOS 17+) pushes a view when an optional binding becomes non-nil and pops it when the value resets to nil. This replaces the common pattern of using a separate `@State var isShowingDetail = false` boolean alongside an optional selection, eliminating an entire class of state synchronization bugs where the boolean and optional get out of sync.

**Incorrect (manual boolean + optional state synchronization):**

```swift
struct OrderListView: View {
    @State private var selectedOrder: Order?
    @State private var isShowingDetail = false

    var body: some View {
        NavigationStack {
            List(orders) { order in
                Button(order.title) {
                    // BAD: Two pieces of state must stay in sync.
                    // If isShowingDetail is true but selectedOrder is nil
                    // (or vice versa), the UI breaks silently.
                    selectedOrder = order
                    isShowingDetail = true
                }
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let order = selectedOrder {
                    OrderDetailView(order: order)
                }
            }
        }
    }
}
```

**Correct (single optional drives navigation):**

```swift
@Equatable
struct OrderListView: View {
    @State private var selectedOrder: Order?

    var body: some View {
        NavigationStack {
            List(orders) { order in
                Button(order.title) {
                    // Single state change drives both push and pop.
                    // Setting to nil pops automatically.
                    selectedOrder = order
                }
            }
            // Pushes when selectedOrder becomes non-nil,
            // pops and resets to nil on back navigation.
            .navigationDestination(item: $selectedOrder) { order in
                OrderDetailView(order: order)
            }
        }
    }
}
```
