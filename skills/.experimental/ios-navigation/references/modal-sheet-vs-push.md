---
title: Use Push for Drill-Down, Sheet for Supplementary Content
impact: HIGH
impactDescription: wrong choice breaks swipe-back for 100% of drill-down flows
tags: modal, sheet, push, navigation-link, mental-model
---

## Use Push for Drill-Down, Sheet for Supplementary Content

Push navigation (NavigationLink) is for hierarchical drill-down where users expect a back button and swipe-back gesture. Sheets are for supplementary, self-contained tasks like forms, filters, or composition flows. Choosing the wrong presentation style breaks the user's mental model of where they are in the app's hierarchy. Sheet presentation must be driven by coordinator-owned state — the coordinator exposes a `presentedSheet` property and views call coordinator methods instead of toggling local @State booleans.

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

**Correct (push for detail, coordinator-driven sheet for supplementary filter):**

```swift
enum SheetRoute: Identifiable {
    case filters

    var id: String {
        switch self {
        case .filters: "filters"
        }
    }
}

@Observable @MainActor
final class ProductListCoordinator {
    var presentedSheet: SheetRoute?

    func presentFilters() {
        presentedSheet = .filters
    }
}

@Equatable
struct ProductListView: View {
    @Environment(ProductListCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

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
                Button("Filters") { coordinator.presentFilters() }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            // GOOD: Filters are a supplementary task — user adjusts criteria
            // and dismisses. Sheet presentation is driven by coordinator-owned
            // state, not a local @State boolean. The coordinator is the single
            // source of truth for what is presented.
            .sheet(item: $coordinator.presentedSheet) { route in
                switch route {
                case .filters:
                    FilterSortView()
                }
            }
        }
    }
}
```
