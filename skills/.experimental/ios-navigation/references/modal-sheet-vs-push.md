---
title: Use Push for Drill-Down, Sheet for Supplementary Content
impact: HIGH
impactDescription: determines whether users can navigate back or must dismiss
tags: modal, sheet, push, navigation-link, mental-model
---

## Use Push for Drill-Down, Sheet for Supplementary Content

Push navigation (NavigationLink) is for hierarchical drill-down where users expect a back button and swipe-back gesture. Sheets are for supplementary, self-contained tasks like forms, filters, or composition flows. Choosing the wrong presentation style breaks the user's mental model of where they are in the app's hierarchy.

Decision matrix: Push = content is part of the navigation hierarchy. Sheet = supplementary task the user can complete and dismiss. FullScreenCover = immersive standalone experience that demands focus.

**Incorrect (using sheet for hierarchical drill-down):**

```swift
struct ProductListView: View {
    @State private var selectedProduct: Product?

    var body: some View {
        // BAD: Product detail is part of the hierarchy, not a supplementary task.
        // Users expect a back button and swipe-back gesture to return to the list.
        // A sheet forces them to dismiss downward, breaking the drill-down mental model.
        List(products) { product in
            Button(product.name) {
                selectedProduct = product
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
}
```

**Correct (push for detail, sheet for supplementary filter):**

```swift
struct ProductListView: View {
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            List(products) { product in
                // GOOD: Product detail is hierarchical drill-down.
                // Users get a back button, swipe-back, and the navigation bar
                // title transitions naturally from "Products" to the product name.
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
            }
            .navigationTitle("Products")
            .toolbar {
                Button("Filters") { showFilters = true }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            // GOOD: Filters are a supplementary task — user adjusts criteria
            // and dismisses. This does not belong in the navigation hierarchy.
            .sheet(isPresented: $showFilters) {
                FilterSortView()
            }
        }
    }
}
```
