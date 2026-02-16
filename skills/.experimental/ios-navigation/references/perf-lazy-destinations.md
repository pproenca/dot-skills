---
title: Use Value-Based NavigationLink for Lazy Destination Construction
impact: MEDIUM-HIGH
impactDescription: eliminates eager construction of 100s of destination views in lists
tags: perf, lazy, navigation-link, value-based
---

## Use Value-Based NavigationLink for Lazy Destination Construction

The legacy `NavigationLink(destination:)` initializer eagerly constructs every destination view at list render time. In a scrollable list of 500 products, that means 500 `ProductDetailView` initializers run — each allocating view models, formatters, and image pipelines — immediately but never displayed. Value-based `NavigationLink(value:)` paired with `.navigationDestination(for:)` defers construction until the user actually taps.

**Incorrect (eager destination construction):**

```swift
// Every DetailView is constructed when the list renders,
// even though the user will only tap 1-2 items.
struct ProductListView: View {
    let products: [Product] // 500 items

    var body: some View {
        NavigationView {
            List(products) { product in
                // BAD: HeavyDetailView is constructed HERE, not on tap.
                // 500 views * ~2KB each = ~1MB of wasted allocations.
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
            }
        }
    }
}

struct ProductDetailView: View {
    // Each instance allocates a view model, date formatter,
    // currency formatter, and image loader on init.
    // NOTE: @ObservedObject is legacy — use plain property with @Observable
    @ObservedObject var viewModel: ProductDetailViewModel

    init(product: Product) {
        // This runs 500 times at list render — not on navigation.
        self.viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView { /* ... */ }
    }
}
```

**Correct (lazy destination via value-based navigation):**

```swift
// Destination is constructed ONLY when the user taps a row.
// Cost goes from O(n) to O(1) at render time.
@Equatable
struct ProductListView: View {
    let products: [Product] // 500 items

    var body: some View {
        NavigationStack {
            List(products) { product in
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .navigationTitle("Products")
        }
    }
}

@Equatable
struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel

    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView { /* ... */ }
    }
}
```
