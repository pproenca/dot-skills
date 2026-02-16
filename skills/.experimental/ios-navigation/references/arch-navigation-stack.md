---
title: Use NavigationStack Over Deprecated NavigationView
impact: CRITICAL
impactDescription: eliminates undefined behavior on iOS 16+
tags: arch, swiftui, navigation, deprecation, ios16
---

## Use NavigationStack Over Deprecated NavigationView

NavigationView was deprecated in iOS 16 and exhibits undefined column behavior on iPad, lacks programmatic navigation, and cannot serialize navigation state for restoration. NavigationStack provides a data-driven path model, type-safe destination registration, and full programmatic control over the back stack. Migrating early prevents accumulating technical debt around a dead API.

**Incorrect (deprecated NavigationView with eager destination construction):**

```swift
// COST: NavigationView is deprecated in iOS 16+. On iPad it defaults to
// DoubleColumnNavigationViewStyle, causing blank detail panes and layout
// bugs. No programmatic push/pop or state restoration support.
// NOTE: @StateObject is also legacy — replaced by @State with @Observable
struct ProductCatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRow(product: product)
                }
            }
            .navigationTitle("Catalog")
        }
        .navigationViewStyle(.stack) // Workaround that won't exist forever
    }
}
```

**Correct (NavigationStack with value-based links and destination registration):**

```swift
// BENEFIT: NavigationStack provides a data-driven path, type-safe
// destinations, lazy view construction, and programmatic navigation.
// State restoration is built-in via Codable NavigationPath.
@Equatable
struct ProductCatalogView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.products) { product in
                NavigationLink(value: Route.product(product)) {
                    ProductRow(product: product)
                }
            }
            .navigationTitle("Catalog")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .product(let product):
                    ProductDetailView(product: product)
                case .category(let category):
                    CategoryView(category: category)
                case .reviews(let productId):
                    ReviewsView(productId: productId)
                }
            }
        }
    }
}
```
