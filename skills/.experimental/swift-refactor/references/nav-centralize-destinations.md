---
title: Refactor Navigation to Coordinator Pattern
impact: HIGH
impactDescription: centralizes navigation logic, enables deep linking, keeps views testable
tags: nav, coordinator, destination, navigationstack, routing
---

## Refactor Navigation to Coordinator Pattern

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Scattered `.navigationDestination(for:)` modifiers across child views cause duplicate registrations and unpredictable routing. Refactor to a coordinator pattern: an `@Observable` class that owns the `NavigationPath` and all routing decisions. Views request navigation by calling coordinator methods — they never create destinations inline. This centralizes flow logic, enables deep linking, and makes navigation testable.

**Incorrect (destinations scattered across child views — no coordinator):**

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

**Correct (coordinator owns NavigationStack and all routing):**

```swift
enum CatalogRoute: Hashable {
    case category(Category)
    case product(Product)
}

@Observable
final class CatalogCoordinator {
    var path = NavigationPath()

    func navigate(to route: CatalogRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func handle(url: URL) -> Bool {
        guard let route = CatalogRoute(url: url) else { return false }
        navigate(to: route)
        return true
    }
}

struct CatalogFlowView: View {
    @State private var coordinator = CatalogCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CategoryListView()
                .navigationDestination(for: CatalogRoute.self) { route in
                    switch route {
                    case .category(let category):
                        ProductListView(category: category)
                    case .product(let product):
                        ProductDetailView(product: product)
                    }
                }
        }
        .environment(coordinator)
    }
}

struct CategoryListView: View {
    @Environment(CatalogCoordinator.self) private var coordinator

    var body: some View {
        List(Category.allCases) { category in
            Button { coordinator.navigate(to: .category(category)) } label: {
                CategoryRow(category: category)
            }
        }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
