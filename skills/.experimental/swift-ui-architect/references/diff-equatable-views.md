---
title: Apply @Equatable Macro to Every SwiftUI View
impact: CRITICAL
impactDescription: 15% scroll hitch reduction measured at Airbnb
tags: diff, equatable, macro, diffing, performance
---

## Apply @Equatable Macro to Every SwiftUI View

SwiftUI's reflection-based diffing fails silently when views contain non-Equatable properties. If ANY stored property isn't diffable, the ENTIRE view becomes non-diffable and its body re-evaluates on every parent update. The `@Equatable` macro generates `Equatable` conformance for all stored properties, excluding `@State`/`@Environment` wrappers. Build fails if a non-Equatable property is added — acting as a compile-time performance linter.

**Incorrect (no @Equatable — SwiftUI can't diff, body always re-evaluates):**

```swift
// Mixed property types: struct + closure
// SwiftUI's reflection can't diff this — body runs on EVERY parent update
struct ProductCard: View {
    let product: Product          // struct — diffable
    let onAddToCart: () -> Void   // closure — NOT diffable

    var body: some View {
        VStack {
            Text(product.name)
            Text(product.price, format: .currency(code: "USD"))
            Button("Add to Cart", action: onAddToCart)
        }
    }
}
```

**Correct (@Equatable macro — guaranteed diffable, body only re-evaluates when data changes):**

```swift
@Equatable
struct ProductCard: View {
    let product: Product                  // struct — included in Equatable
    @SkipEquatable
    let onAddToCart: () -> Void           // closure — excluded from comparison

    var body: some View {
        VStack {
            Text(product.name)
            Text(product.price, format: .currency(code: "USD"))
            Button("Add to Cart", action: onAddToCart)
        }
    }
}
```

**Prerequisite:** The `@Equatable` macro requires the [`ordo-one/equatable`](https://github.com/ordo-one/equatable) SPM package (or equivalent). This is NOT built into SwiftUI. Add it via `Package.swift` or Xcode's package manager. The open-source package uses `@EquatableIgnored` instead of `@SkipEquatable` (which is Airbnb's internal name).

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
// Use with .equatable() modifier or EquatableView wrapper
```

**Benefits:**
- Compile-time guarantee: adding a non-Equatable property without `@EquatableIgnored` fails the build
- Body only re-evaluates when `product` actually changes
- `@State` and `@Environment` wrappers are automatically excluded from comparison

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
