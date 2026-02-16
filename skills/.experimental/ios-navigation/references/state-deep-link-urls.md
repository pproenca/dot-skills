---
title: Parse Deep Link URLs into Route Enums
impact: MEDIUM
impactDescription: O(1) URL-to-route parsing, supports universal links and push notifications
tags: state, deep-link, url, universal-link, open-url
---

## Parse Deep Link URLs into Route Enums

Deep links from universal links, push notifications, Spotlight, and Shortcuts need to be translated into your navigation model. Converting incoming URLs to route enum values and appending them to `NavigationPath` provides a single, testable parsing layer. Clear the existing path before appending deep link routes for predictable, deterministic navigation — otherwise the deep link destination sits on top of whatever the user was previously browsing.

**Incorrect (manual boolean toggling based on URL components):**

```swift
struct ContentView: View {
    @State private var path = NavigationPath()
    // BAD: Fragile boolean flags, each deep link needs new @State variable
    @State private var showProduct = false
    @State private var deepLinkProductId: String?
    @State private var showOrder = false
    @State private var deepLinkOrderId: String?
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                // BAD: Deep link opens on TOP of current navigation
                .sheet(isPresented: $showProduct) {
                    if let id = deepLinkProductId {
                        ProductView(productId: id)
                    }
                }
        }
        .onOpenURL { url in
            // BAD: String matching is fragile, no type safety
            if url.pathComponents.contains("product") {
                deepLinkProductId = url.lastPathComponent
                showProduct = true
            } else if url.pathComponents.contains("order") {
                deepLinkOrderId = url.lastPathComponent
                showOrder = true
            }
        }
    }
}
```

**Correct (URL parsing into route enum with path reset):**

```swift
// Centralized URL-to-Route parsing, testable without UI
enum Route: Hashable, Codable {
    case product(id: String), order(id: String), profile(userId: String), settings, category(slug: String)
    static func fromURL(_ url: URL) -> [Route]? {
        let components = url.pathComponents.filter { $0 != "/" }
        guard let first = components.first else { return nil }
        switch first {
        case "products" where components.count >= 2: return [.product(id: components[1])]
        case "orders" where components.count >= 2: return [.order(id: components[1])]
        case "profile" where components.count >= 2: return [.profile(userId: components[1])]
        case "settings": return [.settings]
        case "categories" where components.count >= 2:
            var routes: [Route] = [.category(slug: components[1])]
            if components.count >= 4, components[2] == "products" {
                routes.append(.product(id: components[3]))
            }
            return routes
        default: return nil
        }
    }
}

@Equatable
struct ContentView: View {
    @State private var path = NavigationPath()
    @SceneStorage("navigation") private var pathData: Data?
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .product(let id): ProductView(productId: id)
                    case .order(let id): OrderView(orderId: id)
                    case .profile(let userId): ProfileView(userId: userId)
                    case .settings: SettingsView()
                    case .category(let slug): CategoryView(slug: slug)
                    }
                }
        }
        .onOpenURL { url in
            guard let routes = Route.fromURL(url) else { return }
            path = NavigationPath(); for route in routes { path.append(route) }
        }
        .onChange(of: path) { newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
    }
}
```
