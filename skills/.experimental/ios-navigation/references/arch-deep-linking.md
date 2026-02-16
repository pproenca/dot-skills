---
title: Handle Deep Links by Appending to NavigationPath
impact: HIGH
impactDescription: enables universal links, push notifications, and Spotlight integration
tags: arch, swiftui, deep-linking, universal-links, navigation-path, url-handling
---

## Handle Deep Links by Appending to NavigationPath

Deep links from universal links, push notifications, Spotlight, and widgets must resolve to the same navigation state as manual user navigation. Converting incoming URLs to route enum values and appending them to NavigationPath ensures consistent behavior regardless of entry point. Manually toggling booleans or presenting views imperatively creates parallel navigation paths that bypass the stack, break the back button, and cannot be serialized for state restoration.

**Incorrect (boolean flags and imperative view presentation for deep links):**

```swift
// COST: Each deep link needs its own boolean and .sheet modifier
// Back stack not updated, user cannot swipe back through deep link path
// State restoration impossible
struct AppRootView: View {
    @State private var showProduct = false
    @State private var deepLinkedProductId: String?
    @State private var showOrder = false
    @State private var deepLinkedOrderId: String?
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .onOpenURL { url in
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let path = components?.path ?? ""
            // Fragile string parsing, no type safety
            if path.contains("product") {
                deepLinkedProductId = path.components(separatedBy: "/").last
                showProduct = true
            } else if path.contains("order") {
                deepLinkedOrderId = path.components(separatedBy: "/").last
                showOrder = true
            }
        }
        .sheet(isPresented: $showProduct) {
            if let id = deepLinkedProductId {
                ProductDetailView(productId: id)
            }
        }
        .sheet(isPresented: $showOrder) {
            if let id = deepLinkedOrderId {
                OrderDetailView(orderId: id)
            }
        }
    }
}
```

**Correct (URL-to-route conversion appended to NavigationPath):**

```swift
// BENEFIT: Deep links produce same navigation state as manual navigation
// Full back stack preserved, state restoration works
@Equatable
struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
        }
        .onOpenURL { coordinator.handleDeepLink($0) }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard let url = activity.webpageURL else { return }
            coordinator.handleDeepLink(url)
        }
    }
}

extension AppCoordinator {
    func handleDeepLink(_ url: URL) {
        guard let routes = DeepLinkParser.parse(url) else { return }
        popToRoot(); for route in routes { navigate(to: route) }
    }
}

enum DeepLinkParser {
    static func parse(_ url: URL) -> [AppRoute]? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return nil }
        let segments = components.path.split(separator: "/").map(String.init)
        switch host {
        case "products":
            guard let productId = segments.first else { return nil }
            return [.productList(categoryId: "all"), .productDetail(productId: productId)]
        case "orders":
            guard let orderId = segments.first else { return nil }
            return [.orderDetail(orderId: orderId)]
        case "sellers":
            guard let sellerId = segments.first else { return nil }
            var routes: [AppRoute] = [.sellerProfile(sellerId: sellerId)]
            if segments.count > 1, segments[1] == "products" {
                routes.insert(.productList(categoryId: "seller-\(sellerId)"), at: 0)
            }
            return routes
        default: return nil
        }
    }
}
```
