---
title: Never Use AnyView in Navigation — Use @ViewBuilder or Generics
impact: HIGH
impactDescription: 3-5× more view re-evaluations — AnyView disables SwiftUI diffing, forcing full-tree re-evaluation on every navigation event instead of targeted updates
tags: arch, anyview, viewbuilder, generics, diffing
---

## Never Use AnyView in Navigation — Use @ViewBuilder or Generics

`AnyView` type-erases the view hierarchy, preventing SwiftUI from diffing efficiently. When used in `navigationDestination` or coordinator view factories, EVERY navigation push/pop forces full-tree re-evaluation instead of targeted updates. Use `@ViewBuilder` for conditional composition and generic constraints for reusable containers.

**Incorrect (AnyView in destination factory — disables diffing):**

```swift
@Observable
final class AppCoordinator {
    var path = NavigationPath()

    // AnyView disables SwiftUI's diffing — every navigation
    // event forces full-tree re-evaluation of the destination
    func destinationView(for route: AppRoute) -> AnyView {
        switch route {
        case .productDetail(let id):
            AnyView(ProductDetailView(productId: id))
        case .sellerProfile(let id):
            AnyView(SellerProfileView(sellerId: id))
        case .settings:
            AnyView(SettingsView())
        }
    }
}
```

**Correct (@ViewBuilder preserves type information for diffing):**

```swift
@Observable @MainActor
final class AppCoordinator {
    var path = NavigationPath()

    // @ViewBuilder preserves concrete types — SwiftUI can diff
    // each branch independently, only updating changed properties
    @ViewBuilder
    func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .productDetail(let id):
            ProductDetailView(productId: id)
        case .sellerProfile(let id):
            SellerProfileView(sellerId: id)
        case .settings:
            SettingsView()
        }
    }
}

@Equatable
struct AppRootView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.destinationView(for: route)
                }
        }
        .environment(coordinator)
    }
}
```

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
