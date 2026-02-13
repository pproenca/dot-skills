---
title: Use @StateObject at Creation Point, @ObservedObject for Passed References
impact: MEDIUM-HIGH
impactDescription: prevents view model recreation on parent re-render
tags: perf, state-object, observed-object, view-model, lifecycle
---

## Use @StateObject at Creation Point, @ObservedObject for Passed References

`@ObservedObject` does not own the object it wraps. If the parent view re-renders (due to any state change), SwiftUI recreates the child view struct, and `@ObservedObject var viewModel = SomeViewModel()` creates a brand-new instance — discarding all loaded data, in-flight requests, and local state. `@StateObject` tells SwiftUI to create the object once and preserve it across parent re-renders. Use `@StateObject` where you create the view model; use `@ObservedObject` only when receiving one from a parent.

**Incorrect (@ObservedObject at creation point — recreated on parent render):**

```swift
struct ProductListView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredProducts) { product in
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Product.self) { product in
                // BAD: Every keystroke in searchable triggers a parent re-render.
                // Each re-render recreates ProductDetailView, which recreates
                // the view model — losing loaded data, resetting scroll position.
                ProductDetailView(product: product)
            }
        }
    }
}

struct ProductDetailView: View {
    // BAD: @ObservedObject does NOT survive parent re-renders.
    // A new DetailViewModel is allocated on every parent body call.
    @ObservedObject var viewModel: ProductDetailViewModel

    init(product: Product) {
        // This initializer runs again on every parent state change.
        self.viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView {
            // Data loaded by .task is lost when viewModel is recreated.
            Text(viewModel.details?.description ?? "Loading...")
        }
        .task { await viewModel.loadDetails() }
    }
}
```

**Correct (@StateObject at creation point — survives parent re-renders):**

```swift
struct ProductListView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredProducts) { product in
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

struct ProductDetailView: View {
    // @StateObject: SwiftUI creates this ONCE and preserves it
    // across parent re-renders. The view model survives searchable
    // keystrokes, tab switches, and other unrelated state changes.
    @StateObject private var viewModel: ProductDetailViewModel

    init(product: Product) {
        // _viewModel = StateObject(wrappedValue:) sets the initial value.
        // SwiftUI only uses this closure on first creation — subsequent
        // parent re-renders reuse the existing instance.
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        ScrollView {
            Text(viewModel.details?.description ?? "Loading...")
        }
        .task { await viewModel.loadDetails() }
    }
}

// When passing a view model DOWN to a child, use @ObservedObject:
struct ProductHeaderView: View {
    // Correct: this view does not CREATE the view model,
    // it receives it from a parent that owns it via @StateObject.
    @ObservedObject var viewModel: ProductDetailViewModel

    var body: some View {
        Text(viewModel.product.name).font(.title)
    }
}
```

**iOS 17+ with @Observable (preferred for new code):**

For projects targeting iOS 17+, `@Observable` replaces `ObservableObject` entirely. The ownership rules simplify: use `@State` where you create the model (replaces `@StateObject`), and pass it as a plain property where received (replaces `@ObservedObject`). Use `@Bindable` when you need two-way bindings.

```swift
// iOS 17+: @Observable replaces ObservableObject.
// @State replaces @StateObject. Plain property replaces @ObservedObject.
@Observable
class ProductDetailViewModel {
    var product: Product
    var details: ProductDetails?

    init(product: Product) { self.product = product }
    func loadDetails() async { /* ... */ }
}

struct ProductDetailView: View {
    // @State owns the object — survives parent re-renders (replaces @StateObject)
    @State private var viewModel: ProductDetailViewModel

    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView {
            Text(viewModel.details?.description ?? "Loading...")
            ProductHeaderView(viewModel: viewModel)
        }
        .task { await viewModel.loadDetails() }
    }
}

struct ProductHeaderView: View {
    // Plain property — no wrapper needed (replaces @ObservedObject)
    var viewModel: ProductDetailViewModel

    var body: some View {
        Text(viewModel.product.name).font(.title)
    }
}
```
