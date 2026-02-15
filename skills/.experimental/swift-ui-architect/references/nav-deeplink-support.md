---
title: Coordinators Must Support URL-Based Deep Linking
impact: MEDIUM-HIGH
impactDescription: enables push notifications, universal links, and external navigation
tags: nav, deeplink, universal-links, url, coordinator
---

## Coordinators Must Support URL-Based Deep Linking

Every coordinator must implement a method to resolve a URL into a Route. This enables push notification handling, universal links, Spotlight integration, and inter-feature navigation. The app-level coordinator dispatches URLs to feature coordinators, which push the appropriate route onto their NavigationStack.

**Incorrect (deep link handling in SceneDelegate with manual view creation — fragile, duplicated):**

```swift
// Deep link handling outside the navigation system
// Duplicates view creation logic, breaks when routes change
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        // Manual URL parsing — no connection to the Route enum
        if url.path.contains("order") {
            let id = url.lastPathComponent
            // Manually creating views — duplicates coordinator logic
            let detailView = OrderDetailView(orderId: id)
            // How to push this onto NavigationStack from here?
            // Usually involves global state or NotificationCenter hacks
            NotificationCenter.default.post(
                name: .navigateToOrder,
                object: nil,
                userInfo: ["view": detailView]  // This doesn't even work
            )
        }
    }
}
```

**Correct (coordinators resolve URLs to typed routes — unified navigation path):**

```swift
// Protocol — every feature coordinator supports deep linking
protocol DeepLinkable {
    func handle(url: URL) -> Bool
}

// App-level coordinator dispatches to feature coordinators
@Observable
final class AppCoordinator: DeepLinkable {
    var selectedTab: AppTab = .home
    let orderCoordinator = OrderCoordinator()
    let profileCoordinator = ProfileCoordinator()

    func handle(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        // Dispatch to the appropriate feature coordinator
        switch components.host {
        case "orders":
            selectedTab = .orders
            return orderCoordinator.handle(url: url)
        case "profile":
            selectedTab = .profile
            return profileCoordinator.handle(url: url)
        default:
            return false
        }
    }
}

// Feature coordinator resolves URL to its Route enum
@Observable
final class OrderCoordinator: DeepLinkable {
    var path = NavigationPath()

    func handle(url: URL) -> Bool {
        // Reuses the same Route enum used for in-app navigation
        guard let route = OrderRoute(url: url) else { return false }

        // Same navigate() method used everywhere
        // Deep link and in-app navigation follow identical paths
        navigate(to: route)
        return true
    }

    func navigate(to route: OrderRoute) {
        path.append(route)
    }
}

// Register at app level — universal links, push notifications, Spotlight
@main
struct MyApp: App {
    @State private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environment(appCoordinator)
                // Universal links
                .onOpenURL { url in
                    _ = appCoordinator.handle(url: url)
                }
                // Push notification deep links
                .onReceive(NotificationCenter.default.publisher(for: .deepLink)) { notification in
                    if let url = notification.userInfo?["url"] as? URL {
                        _ = appCoordinator.handle(url: url)
                    }
                }
        }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
