---
title: Apply @Equatable Macro to Every Navigation View
impact: CRITICAL
impactDescription: 15% scroll hitch reduction measured at Airbnb — single highest-impact SwiftUI optimization
tags: arch, equatable, diffing, performance, macro
---

## Apply @Equatable Macro to Every Navigation View

SwiftUI's reflection-based diffing fails silently when views contain non-Equatable properties. If ANY stored property isn't diffable, the ENTIRE view body re-evaluates on every parent update — including every navigation push, pop, and tab switch. The `@Equatable` macro generates `Equatable` conformance for all stored properties, excluding `@State`/`@Environment` wrappers. Build fails if a non-Equatable property is added without `@SkipEquatable` — acting as a compile-time performance linter.

**Incorrect (no @Equatable — body re-evaluates on every parent update):**

```swift
// Navigation destination view without @Equatable
// Body re-evaluates on EVERY parent state change, even if
// product hasn't changed. In a list of 50 items, this means
// 50 unnecessary body evaluations per state change.
struct ProductDetailView: View {
    let productId: String
    let onAddToCart: () -> Void  // closure — NOT diffable

    var body: some View {
        ScrollView {
            Text(productId)
            Button("Add to Cart", action: onAddToCart)
        }
        .navigationTitle("Product")
    }
}
```

**Correct (@Equatable macro — body only re-evaluates when data changes):**

```swift
// @Equatable generates Equatable conformance for all stored properties
// @SkipEquatable excludes closures from comparison
// @State and @Environment are automatically excluded
@Equatable
struct ProductDetailView: View {
    let productId: String
    @SkipEquatable
    let onAddToCart: () -> Void  // excluded from comparison

    var body: some View {
        ScrollView {
            Text(productId)
            Button("Add to Cart", action: onAddToCart)
        }
        .navigationTitle("Product")
    }
}
```

**Prerequisite:** The `@Equatable` macro requires the [`ordo-one/equatable`](https://github.com/ordo-one/equatable) SPM package. Add it via `Package.swift` or Xcode's package manager. The open-source package uses `@EquatableIgnored` instead of `@SkipEquatable` (Airbnb's internal name).

**Alternative (built-in SwiftUI, no third-party dependency):**

```swift
struct ProductDetailView: View, Equatable {
    let productId: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.productId == rhs.productId
    }

    var body: some View {
        ScrollView {
            Text(productId)
        }
        .navigationTitle("Product")
    }
}
```

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
