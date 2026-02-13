---
title: Avoid Heavy Work in View Initializers
impact: HIGH
impactDescription: causes hitches on navigation push, blocks main thread
tags: anti, performance, init, view-lifecycle
---

## Avoid Heavy Work in View Initializers

SwiftUI may construct destination views eagerly -- especially with `NavigationLink(destination:)` on pre-iOS 16 and during prefetching in lazy containers. Heavy work in `init()` (network calls, database queries, large allocations) blocks the main thread during the push animation, causing visible frame drops and hitches. The fix is to keep initializers lightweight and defer all real work to `.task {}` or `.onAppear`.

**Incorrect (expensive work in init blocks the push animation):**

```swift
// BAD: The view model fetches data synchronously in init().
// When NavigationLink constructs this view, the main thread
// stalls for 200-800ms depending on network/database speed,
// causing a visible hitch in the push animation.
struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel

    init(productId: String) {
        // Heavy work: synchronous database query + JSON parsing
        let product = ProductDatabase.shared.fetchSync(id: productId)
        let recommendations = RecommendationEngine.shared
            .computeSync(for: product)
        _viewModel = StateObject(
            wrappedValue: ProductDetailViewModel(
                product: product,
                recommendations: recommendations
            )
        )
    }

    var body: some View {
        ProductContent(viewModel: viewModel)
    }
}
```

**Correct (lightweight init with deferred async loading):**

```swift
// GOOD: init() only stores the product ID — near-zero cost.
// All expensive work runs asynchronously in .task {},
// which fires after the view appears on screen so the
// push animation stays at a smooth 60fps.
struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel

    init(productId: String) {
        // Lightweight: just capture the ID, no I/O
        _viewModel = StateObject(
            wrappedValue: ProductDetailViewModel(productId: productId)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ProductContent(viewModel: viewModel)
            }
        }
        .task {
            // Async work runs off the main actor during load,
            // then publishes results back to the @Published properties.
            await viewModel.loadProduct()
            await viewModel.loadRecommendations()
        }
    }
}

@MainActor
final class ProductDetailViewModel: ObservableObject {
    let productId: String
    @Published var product: Product?
    @Published var recommendations: [Product] = []
    @Published var isLoading = true

    init(productId: String) {
        self.productId = productId // No I/O in init
    }

    func loadProduct() async {
        product = await ProductDatabase.shared.fetch(id: productId)
    }

    func loadRecommendations() async {
        guard let product else { return }
        recommendations = await RecommendationEngine.shared
            .compute(for: product)
        isLoading = false
    }
}
```
