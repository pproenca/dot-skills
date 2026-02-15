---
title: Leverage @Observable Property-Level Tracking
impact: HIGH
impactDescription: 2-10x fewer view updates compared to ObservableObject
tags: state, observable, scoping, granular, tracking
---

## Leverage @Observable Property-Level Tracking

`@Observable` automatically tracks which properties are read during body evaluation and only invalidates views that read changed properties. This means a ViewModel with 10 properties only triggers re-render in views that read the specific changed property. Design ViewModels with this in mind — separate frequently-changing properties from stable ones.

**Incorrect (single view reading all properties — loading state triggers full list re-render):**

```swift
@Observable
class CatalogViewModel {
    var products: [Product] = []
    var isLoading: Bool = false
    var searchQuery: String = ""
    var selectedCategory: Category?
}

struct CatalogView: View {
    @State var viewModel = CatalogViewModel()

    var body: some View {
        VStack {
            // This view reads isLoading, products, AND searchQuery
            // When isLoading toggles, the ENTIRE VStack re-evaluates
            // including the expensive product list
            if viewModel.isLoading {
                ProgressView()
            }

            SearchBar(text: $viewModel.searchQuery)

            List(viewModel.products) { product in
                ProductRow(product: product)
            }
        }
    }
}
```

**Correct (extracted subviews — each reads only what it needs):**

```swift
@Observable
class CatalogViewModel {
    var products: [Product] = []
    var isLoading: Bool = false
    var searchQuery: String = ""
    var selectedCategory: Category?
}

struct CatalogView: View {
    @State var viewModel = CatalogViewModel()

    var body: some View {
        VStack {
            // Each subview only reads the properties it needs
            // isLoading change does NOT re-render ProductListView
            LoadingIndicator(viewModel: viewModel)
            CatalogSearchBar(viewModel: viewModel)
            ProductListView(viewModel: viewModel)
        }
    }
}

// Only re-renders when isLoading changes
struct LoadingIndicator: View {
    let viewModel: CatalogViewModel

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        }
    }
}

// Only re-renders when searchQuery changes
struct CatalogSearchBar: View {
    @Bindable var viewModel: CatalogViewModel

    var body: some View {
        TextField("Search", text: $viewModel.searchQuery)
    }
}

// Only re-renders when products changes
struct ProductListView: View {
    let viewModel: CatalogViewModel

    var body: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
        }
    }
}
```

**Key insight:** `@Observable` tracking is per-view-body, not per-object. The same ViewModel instance can be passed to multiple subviews, and each will only re-render for properties it actually reads.

Reference: [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/wwdc23/10149)
