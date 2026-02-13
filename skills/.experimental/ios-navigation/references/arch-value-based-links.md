---
title: Use Value-Based NavigationLink Over Destination Closures
impact: CRITICAL
impactDescription: prevents eager view construction, enables type-safe routing
tags: arch, swiftui, navigation-link, performance, lazy-loading
---

## Use Value-Based NavigationLink Over Destination Closures

NavigationLink(destination:) eagerly constructs the destination view and its entire dependency graph for every visible row, even if the user never taps it. In a list of 100 items this means 100 fully-initialized detail views in memory. Value-based NavigationLink defers construction until the push occurs, integrates with NavigationPath for programmatic control, and enforces type-safe routing through the destination registration pattern.

**Incorrect (destination closure eagerly allocates views):**

```swift
// COST: Each NavigationLink immediately constructs a ProductDetailView,
// including its view model, network layer, and image prefetch pipeline.
// For a list of 200 products this creates 200 detail view graphs on
// first render, spiking memory significantly and delaying initial display.
struct ProductListView: View {
    let products: [Product]

    var body: some View {
        List(products) { product in
            NavigationLink(destination: ProductDetailView(
                viewModel: ProductDetailViewModel(
                    product: product,
                    repository: ProductRepository(),
                    imageLoader: ImageLoader()
                )
            )) {
                ProductRow(product: product)
            }
        }
    }
}
```

**Correct (value-based link with lazy destination resolution):**

```swift
// BENEFIT: Only the Hashable value is stored per row. The destination
// view is constructed lazily when the user actually navigates. Memory
// stays flat regardless of list size, and the value integrates with
// NavigationPath for programmatic push/pop and deep linking.
struct ProductListView: View {
    let products: [Product]

    var body: some View {
        List(products) { product in
            NavigationLink(value: Route.productDetail(product.id)) {
                ProductRow(product: product)
            }
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .productDetail(let productId):
                ProductDetailView(
                    viewModel: ProductDetailViewModel(productId: productId)
                )
            case .sellerProfile(let sellerId):
                SellerProfileView(sellerId: sellerId)
            case .reviewsList(let productId):
                ReviewsListView(productId: productId)
            }
        }
    }
}
```
