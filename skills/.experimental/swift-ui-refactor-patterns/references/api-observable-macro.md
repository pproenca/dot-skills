---
title: Migrate ObservableObject to @Observable Macro
impact: CRITICAL
impactDescription: eliminates over-observation, 2-5x fewer re-renders
tags: api, observable, observation, state-management, migration
---

## Migrate ObservableObject to @Observable Macro

ObservableObject uses push-based notification: any @Published property change triggers re-renders in every observing view, even those that don't read the changed property. The @Observable macro (iOS 17+) uses pull-based tracking, where SwiftUI observes only the specific properties each view accesses. This eliminates over-observation and can reduce re-renders by 2-5x in views with multiple observed properties.

**Incorrect (push-based notification re-renders all observers):**

```swift
class ShoppingCart: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var couponCode: String = ""
    @Published var isCheckingOut: Bool = false
    // Changing couponCode re-renders views that only read items
}

struct CartBadge: View {
    @ObservedObject var cart: ShoppingCart

    var body: some View {
        // Re-renders when couponCode or isCheckingOut changes,
        // even though it only reads items.count
        Text("\(cart.items.count)")
    }
}

struct CartScreen: View {
    @StateObject private var cart = ShoppingCart()

    var body: some View {
        CartBadge(cart: cart)
    }
}
```

**Correct (pull-based tracking re-renders only affected views):**

```swift
@Observable
class ShoppingCart {
    var items: [CartItem] = []
    var couponCode: String = ""
    var isCheckingOut: Bool = false
    // SwiftUI tracks which properties each view reads
}

struct CartBadge: View {
    var cart: ShoppingCart

    var body: some View {
        // Only re-renders when items.count actually changes
        Text("\(cart.items.count)")
    }
}

struct CartScreen: View {
    @State private var cart = ShoppingCart()

    var body: some View {
        CartBadge(cart: cart)
    }
}
```

Reference: [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
