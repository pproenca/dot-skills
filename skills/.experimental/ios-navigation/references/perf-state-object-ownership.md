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
@Equatable
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

@Equatable
struct ProductHeaderView: View {
    // Plain property — no wrapper needed for read access.
    var viewModel: ProductDetailViewModel

    var body: some View {
        Text(viewModel.product.name).font(.title)
    }
}

@Observable @MainActor
class ProductDetailViewModel {
    var product: Product
    var details: ProductDetails?

    init(product: Product) { self.product = product }
    func loadDetails() async { /* ... */ }
}
```
