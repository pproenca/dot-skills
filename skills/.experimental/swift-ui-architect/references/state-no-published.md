---
title: Never Use @Published or ObservableObject
impact: HIGH
impactDescription: O(1) targeted re-renders vs O(N) broadcast — N = number of observing views
tags: state, published, observable-object, deprecated, migration
---

## Never Use @Published or ObservableObject

With iOS 17+ as the minimum target, `@Published` and `ObservableObject` are strictly prohibited. `@Published` notifies ALL subscribing views when ANY property changes, regardless of which properties each view actually reads. This causes O(N) unnecessary re-renders where N is the number of observing views. `@Observable` tracks property access at the view level, reducing this to O(1).

**Incorrect (ObservableObject with @Published — O(N) re-renders):**

```swift
// Every @Published change notifies ALL subscribers
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var isCheckingOut: Bool = false
    @Published var promoCode: String = ""
    @Published var shippingOption: ShippingOption = .standard
}

struct CartView: View {
    @StateObject var viewModel = CartViewModel()

    var body: some View {
        VStack {
            CartItemList(viewModel: viewModel)    // re-renders when promoCode changes
            PromoCodeField(viewModel: viewModel)   // re-renders when items changes
            ShippingPicker(viewModel: viewModel)   // re-renders when isCheckingOut changes
            CheckoutButton(viewModel: viewModel)   // re-renders when shippingOption changes
        }
    }
}

// ALL four subviews re-render when ANY property changes
// Typing in PromoCodeField causes CartItemList to re-render
```

**Correct (@Observable — O(1) re-renders, only affected views update):**

```swift
// @Observable tracks which properties each view reads
@Observable
class CartViewModel {
    var items: [CartItem] = []           // plain var, not @Published
    var isCheckingOut: Bool = false
    var promoCode: String = ""
    var shippingOption: ShippingOption = .standard

    var total: Decimal {
        items.reduce(0) { $0 + $1.price }
    }
}

struct CartView: View {
    @State var viewModel = CartViewModel()  // @State, not @StateObject

    var body: some View {
        VStack {
            CartItemList(viewModel: viewModel)
            PromoCodeField(viewModel: viewModel)
            ShippingPicker(viewModel: viewModel)
            CheckoutButton(viewModel: viewModel)
        }
    }
}

// Typing in PromoCodeField ONLY re-renders PromoCodeField
// CartItemList is untouched — it only reads 'items'
```

**Migration checklist:**
- `ObservableObject` → `@Observable`
- `@Published var` → plain `var`
- `@StateObject` → `@State`
- `@ObservedObject` → plain property (let/var)
- `@EnvironmentObject` → `@Environment`

**When NOT to use this rule:** Only if supporting iOS 15/16 backward compatibility (which this architecture does NOT target).

Reference: [SwiftLee — @Observable macro performance increase](https://www.avanderlee.com/swiftui/observable-macro-performance-increase-observation/)
