---
title: Minimize State Scope to Reduce Re-renders
impact: CRITICAL
impactDescription: isolates re-renders to smallest possible view subtree
tags: state, scope, re-renders, optimization
---

## Minimize State Scope to Reduce Re-renders

Place state in the lowest view that needs it. When state changes, only that view and its children re-render. State too high up causes unnecessary work.

**Incorrect (state at top causes full re-render):**

```swift
struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var searchText = ""  // Every keystroke re-renders entire list
    @State private var selectedProduct: Product?

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)

            List(filteredProducts) { product in
                ProductRow(product: product)  // All rows re-render on search
            }
        }
    }
}
```

**Correct (search state isolated):**

```swift
struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?

    var body: some View {
        VStack {
            SearchField(products: products, onSelect: { selectedProduct = $0 })

            List(products) { product in
                ProductRow(product: product)  // Only re-renders when products change
            }
        }
    }
}

struct SearchField: View {
    let products: [Product]
    let onSelect: (Product) -> Void
    @State private var searchText = ""  // Isolated state

    var filteredProducts: [Product] {
        products.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        // Only this view re-renders on keystroke
        TextField("Search", text: $searchText)
    }
}
```

**Rule of thumb:** If a piece of state only affects one view subtree, move it into that subtree.

Reference: [Understanding and Improving SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
