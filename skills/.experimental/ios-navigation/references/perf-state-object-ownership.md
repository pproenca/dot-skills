---
title: Own @Observable State with @State, Pass as Plain Property
impact: MEDIUM-HIGH
impactDescription: prevents model recreation on every parent re-render
tags: perf, observable, state, view-model, lifecycle
---

## Own @Observable State with @State, Pass as Plain Property

Use `@State` where you create an `@Observable` model — SwiftUI preserves the instance across parent re-renders. Pass it to children as a plain property (no wrapper needed). Use `@Bindable` when you need two-way bindings to the model's properties.

**Important caveat:** Unlike the legacy `@StateObject` (which uses `@autoclosure`), `@State` with an `@Observable` class runs the initializer on every parent body evaluation — SwiftUI discards the extra instances, but side effects in `init()` (network calls, analytics, file I/O) still fire. Keep `@Observable` initializers lightweight and move expensive setup to `.task`.

**Incorrect (model recreated on parent re-render):**

```swift
struct ProductDetailView: View {
    // BAD: plain property with no ownership — a new ViewModel
    // is created on every parent body call, losing loaded data.
    var viewModel: ProductDetailViewModel

    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView {
            Text(viewModel.details?.description ?? "Loading...")
        }
        .task { await viewModel.loadDetails() }
    }
}
```

**Correct (@State owns the model — survives parent re-renders):**

```swift
struct ProductDetailView: View {
    // @State owns the object — survives parent re-renders.
    @State private var viewModel: ProductDetailViewModel

    init(product: Product) {
        // Keep init lightweight — no network calls or I/O here.
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
    // Plain property — no wrapper needed for read access.
    var viewModel: ProductDetailViewModel

    var body: some View {
        Text(viewModel.product.name).font(.title)
    }
}

@Observable
class ProductDetailViewModel {
    var product: Product
    var details: ProductDetails?

    init(product: Product) { self.product = product }
    func loadDetails() async { /* ... */ }
}
```

**Legacy (iOS 16 and below — @StateObject / @ObservedObject):**

For codebases targeting iOS 16 or below where `@Observable` is unavailable, use `@StateObject` at the creation point and `@ObservedObject` when receiving from a parent. `@StateObject` uses `@autoclosure` for true lazy initialization — the wrapped value initializer runs only once, unlike `@State` with `@Observable`.

```swift
struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel

    init(product: Product) {
        _viewModel = StateObject(
            wrappedValue: ProductDetailViewModel(product: product)
        )
    }

    var body: some View {
        ScrollView {
            Text(viewModel.details?.description ?? "Loading...")
        }
        .task { await viewModel.loadDetails() }
    }
}
```
