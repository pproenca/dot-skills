---
title: Decompose Views to Limit State Invalidation Blast Radius
impact: HIGH
impactDescription: extracting subviews reduces unnecessary body re-evaluations from O(parent-tree) to O(affected-subtree), preventing cascading redraws
tags: perf, decomposition, state, invalidation, subview, granularity
---

## Decompose Views to Limit State Invalidation Blast Radius

When a `@State` or `@Observable` property changes, SwiftUI re-evaluates the `body` of the view that owns or reads that property -- plus all child views constructed inline. In a monolithic view, a single counter increment re-evaluates hundreds of lines of body. Extracting independent subtrees into separate view structs limits invalidation to only the subtree that depends on the changed state.

**Incorrect (monolithic view -- any state change re-evaluates entire body):**

```swift
struct OrderDetailView: View {
    @State private var quantity = 1
    @State private var selectedShipping: ShippingMethod = .standard
    let product: Product

    var body: some View {
        ScrollView {
            // Product header -- re-evaluated when quantity changes
            VStack {
                AsyncImage(url: product.imageURL)
                    .frame(height: 300)
                Text(product.name).font(.title)
                Text(product.description).font(.body)
                StarRating(rating: product.rating)
            }

            // Quantity picker -- owns the state
            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)

            // Shipping section -- re-evaluated when quantity changes
            ForEach(ShippingMethod.allCases) { method in
                ShippingOptionRow(
                    method: method,
                    isSelected: selectedShipping == method
                )
                .onTapGesture { selectedShipping = method }
            }

            // Price summary -- re-evaluated when quantity changes
            PriceSummary(
                unitPrice: product.price,
                quantity: quantity,
                shipping: selectedShipping
            )
        }
    }
}
```

**Correct (decomposed -- each section only re-evaluates when its inputs change):**

```swift
struct OrderDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var selectedShipping: ShippingMethod = .standard

    var body: some View {
        ScrollView {
            ProductHeader(product: product)
            QuantityPicker(quantity: $quantity)
            ShippingSelector(selected: $selectedShipping)
            PriceSummary(
                unitPrice: product.price,
                quantity: quantity,
                shipping: selectedShipping
            )
        }
    }
}

// Only re-evaluated when product changes (which is rare)
private struct ProductHeader: View {
    let product: Product

    var body: some View {
        VStack {
            AsyncImage(url: product.imageURL)
                .frame(height: 300)
            Text(product.name).font(.title)
            Text(product.description).font(.body)
            StarRating(rating: product.rating)
        }
    }
}

// Only re-evaluated when quantity binding fires
private struct QuantityPicker: View {
    @Binding var quantity: Int

    var body: some View {
        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
    }
}

// Only re-evaluated when selectedShipping binding fires
private struct ShippingSelector: View {
    @Binding var selected: ShippingMethod

    var body: some View {
        ForEach(ShippingMethod.allCases) { method in
            ShippingOptionRow(method: method, isSelected: selected == method)
                .onTapGesture { selected = method }
        }
    }
}
```

**Guidelines:**
- Extract any section that does not depend on frequently-changing state
- Pass only the minimum data each subview needs (`@Binding` for mutable, `let` for read-only)
- Use `private struct` for subviews that are only used by one parent
- Profile with Instruments > SwiftUI to verify which views re-evaluate

**When NOT to decompose:**
- Views with < 5 child elements and no expensive computations
- When all children depend on the same state (decomposition adds structure without reducing work)

Reference: [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance)
