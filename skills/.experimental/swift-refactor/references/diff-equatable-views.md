---
title: Add @Equatable Macro to Every SwiftUI View
impact: CRITICAL
impactDescription: 15% scroll hitch reduction measured at Airbnb — guaranteed diffable views
tags: diff, equatable, macro, diffing, performance
---

## Add @Equatable Macro to Every SwiftUI View

SwiftUI's reflection-based diffing fails silently when views contain non-Equatable properties. If ANY stored property isn't diffable, the ENTIRE view becomes non-diffable and its body re-evaluates on every parent update. Add the `@Equatable` macro to every view — it generates `Equatable` conformance for all stored properties and fails the build if a non-Equatable property is added without `@EquatableIgnored`.

**Incorrect (no @Equatable — SwiftUI can't diff, body always re-evaluates):**

```swift
struct ProductCard: View {
    let product: Product          // struct — diffable
    let onAddToCart: () -> Void   // closure — NOT diffable
    // SwiftUI's reflection can't diff this — body runs on EVERY parent update

    var body: some View {
        VStack {
            Text(product.name)
            Text(product.price, format: .currency(code: "USD"))
            Button("Add to Cart", action: onAddToCart)
        }
    }
}
```

**Correct (@Equatable — guaranteed diffable, body only re-evaluates when data changes):**

```swift
@Equatable
struct ProductCard: View {
    let product: Product                  // included in Equatable comparison
    @EquatableIgnored
    let onAddToCart: () -> Void           // closure excluded from comparison

    var body: some View {
        VStack {
            Text(product.name)
            Text(product.price, format: .currency(code: "USD"))
            Button("Add to Cart", action: onAddToCart)
        }
    }
}
// Build fails if a non-Equatable property is added without @EquatableIgnored
// @State and @Environment wrappers are automatically excluded
```

**Alternative (built-in SwiftUI, no third-party dependency):**

```swift
struct ProductCard: View, Equatable {
    let product: Product

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.product == rhs.product
    }

    var body: some View {
        VStack {
            Text(product.name)
            Text(product.price, format: .currency(code: "USD"))
        }
    }
}
```

**Prerequisite:** The `@Equatable` macro requires the [`ordo-one/equatable`](https://github.com/ordo-one/equatable) SPM package. Add it via `Package.swift` or Xcode's package manager.

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
