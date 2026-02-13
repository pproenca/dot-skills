---
title: Parse Deep Link URLs into Route Enums
impact: MEDIUM
impactDescription: supports universal links, push notifications, and Spotlight
tags: state, deep-link, url, universal-link, open-url
---

## Parse Deep Link URLs into Route Enums

Deep links from universal links, push notifications, Spotlight, and Shortcuts need to be translated into your navigation model. Converting incoming URLs to route enum values and appending them to `NavigationPath` provides a single, testable parsing layer. Clear the existing path before appending deep link routes for predictable, deterministic navigation — otherwise the deep link destination sits on top of whatever the user was previously browsing.

**Incorrect (manual boolean toggling based on URL components):**

```swift
struct ContentView: View {
    @State private var path = NavigationPath()

    // BAD: Fragile boolean flags for deep link state.
    // Adding a new deep link requires a new @State variable,
    // a new if-else branch, and manual cleanup logic.
    @State private var showProduct = false
    @State private var deepLinkProductId: String?
    @State private var showOrder = false
    @State private var deepLinkOrderId: String?
    @State private var showProfile = false

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                // BAD: Deep link opens on TOP of current navigation.
                // User was 3 levels deep, now they have
                // 4 levels — confusing back button behavior.
                .sheet(isPresented: $showProduct) {
                    if let id = deepLinkProductId {
                        ProductView(productId: id)
                    }
                }
        }
        .onOpenURL { url in
            // BAD: String matching on URL paths is fragile.
            // No type safety, no exhaustive handling.
            if url.pathComponents.contains("product") {
                deepLinkProductId = url.lastPathComponent
                showProduct = true
            } else if url.pathComponents.contains("order") {
                deepLinkOrderId = url.lastPathComponent
                showOrder = true
            }
            // Missing: cleanup of previous flags, resetting path
        }
    }
}
```

**Correct (URL parsing into route enum with path reset):**

```swift
// Centralized URL-to-Route parsing. Testable without any UI.
enum Route: Hashable, Codable {
    case product(id: String)
    case order(id: String)
    case profile(userId: String)
    case settings
    case category(slug: String)

    // Factory method: parse any incoming URL into a list of routes.
    // Returns an array to support deep paths like /orders/123/tracking.
    static func fromURL(_ url: URL) -> [Route]? {
        // Normalize: strip leading slash, split into components.
        // Example: myapp://app/products/abc-123 -> ["products", "abc-123"]
        let components = url.pathComponents.filter { $0 != "/" }

        guard let first = components.first else { return nil }

        switch first {
        case "products" where components.count >= 2:
            return [.product(id: components[1])]

        case "orders" where components.count >= 2:
            return [.order(id: components[1])]

        case "profile" where components.count >= 2:
            return [.profile(userId: components[1])]

        case "settings":
            return [.settings]

        case "categories" where components.count >= 2:
            // Deep path: navigate to category, then product if specified.
            var routes: [Route] = [.category(slug: components[1])]
            if components.count >= 4, components[2] == "products" {
                routes.append(.product(id: components[3]))
            }
            return routes

        default:
            return nil
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @SceneStorage("navigation") private var pathData: Data?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .product(let id):
                        ProductView(productId: id)
                    case .order(let id):
                        OrderView(orderId: id)
                    case .profile(let userId):
                        ProfileView(userId: userId)
                    case .settings:
                        SettingsView()
                    case .category(let slug):
                        CategoryView(slug: slug)
                    }
                }
        }
        // Handle deep links from universal links, push notifications, etc.
        .onOpenURL { url in
            guard let routes = Route.fromURL(url) else { return }

            // IMPORTANT: Clear existing path for predictable navigation.
            // Deep link always starts from root -> destination.
            // Without this, the deep link stacks on top of whatever
            // the user was previously browsing.
            path = NavigationPath()

            // Append all routes in order — supports multi-level deep links.
            for route in routes {
                path.append(route)
            }
        }
        // Persist path changes for state restoration.
        .onChange(of: path) { newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
    }
}

// Unit testable without SwiftUI:
// func testProductDeepLink() {
//     let url = URL(string: "myapp://app/products/abc-123")!
//     let routes = Route.fromURL(url)
//     XCTAssertEqual(routes, [.product(id: "abc-123")])
// }
```
