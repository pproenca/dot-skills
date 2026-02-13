---
title: Register navigationDestination at Stack Root
impact: CRITICAL
impactDescription: prevents undefined behavior and race conditions
tags: arch, swiftui, navigation-destination, registration, stack
---

## Register navigationDestination at Stack Root

When `.navigationDestination(for:)` modifiers are scattered across child views, SwiftUI may encounter duplicate registrations for the same type, or fail to find a registration that has not yet appeared in the view hierarchy. This causes silent navigation failures, crashes, or race conditions where the destination resolves differently depending on which child rendered first. Registering all destinations once at the NavigationStack root guarantees deterministic resolution and makes the navigation contract explicit.

**Incorrect (destination registrations scattered across child views):**

```swift
// COST: Each child registers its own .navigationDestination, leading to
// duplicate registrations for the same type. SwiftUI picks one
// non-deterministically, causing the wrong detail view to appear or
// navigation to silently fail when a child hasn't rendered yet.
struct CatalogTab: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CatalogGrid()
        }
    }
}

struct CatalogGrid: View {
    let products: [Product]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    ProductCard(product: product)
                }
            }
        }
        // Registration buried in child — may conflict with other registrations
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
    }
}

struct SearchResultsView: View {
    let results: [Product]

    var body: some View {
        List(results) { product in
            NavigationLink(value: product) { ProductRow(product: product) }
        }
        // Duplicate registration for Product.self — undefined behavior
        .navigationDestination(for: Product.self) { product in
            SearchProductDetailView(product: product)
        }
    }
}
```

**Correct (single destination registration at NavigationStack root using route enum):**

```swift
// BENEFIT: All destinations registered once at the stack root. No
// duplicates, no race conditions, deterministic resolution. Adding
// a new route is a single case in the enum and a single switch branch.
struct CatalogTab: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CatalogGrid()
                .navigationDestination(for: CatalogRoute.self) { route in
                    switch route {
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    case .categoryListing(let category):
                        CategoryListingView(category: category)
                    case .sellerStore(let sellerId):
                        SellerStoreView(sellerId: sellerId)
                    case .searchResults(let query):
                        SearchResultsView(query: query)
                    }
                }
        }
    }
}

struct CatalogGrid: View {
    let products: [Product]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(products) { product in
                // Child views only push values — no destination registration
                NavigationLink(value: CatalogRoute.productDetail(product)) {
                    ProductCard(product: product)
                }
            }
        }
    }
}
```
