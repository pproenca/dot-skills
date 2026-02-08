---
title: Centralize navigationDestination at Stack Root
impact: HIGH
impactDescription: prevents duplicate destination registrations and routing conflicts
tags: nav, destination, centralize, routing, navigationstack
---

## Centralize navigationDestination at Stack Root

When `.navigationDestination(for:)` modifiers are scattered across child views, SwiftUI may register the same type multiple times, leading to duplicate registrations and unpredictable routing where the wrong destination view appears. Centralizing all destination modifiers at the NavigationStack root ensures each type is registered exactly once and makes the routing table immediately visible in a single location.

**Incorrect (destination modifiers scattered across child views):**

```swift
struct AppRootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CategoryListView()
        }
    }
}

struct CategoryListView: View {
    var body: some View {
        List(Category.allCases) { category in
            NavigationLink(value: category) {
                CategoryRow(category: category)
            }
        }
        .navigationDestination(for: Category.self) { category in
            ProductListView(category: category)
        }
    }
}

struct ProductListView: View {
    let category: Category

    var body: some View {
        List(category.products) { product in
            NavigationLink(value: product) {
                ProductRow(product: product)
            }
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
    }
}
```

**Correct (all destinations centralized at NavigationStack root):**

```swift
struct AppRootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CategoryListView()
                .navigationDestination(for: Category.self) { category in
                    ProductListView(category: category)
                }
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
        }
    }
}

struct CategoryListView: View {
    var body: some View {
        List(Category.allCases) { category in
            NavigationLink(value: category) {
                CategoryRow(category: category)
            }
        }
    }
}

struct ProductListView: View {
    let category: Category

    var body: some View {
        List(category.products) { product in
            NavigationLink(value: product) {
                ProductRow(product: product)
            }
        }
    }
}
```

Reference: [Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)
