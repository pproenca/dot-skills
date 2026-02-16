---
title: Define Routes as Hashable Enums
impact: CRITICAL
impactDescription: enables type-safe navigation, deep linking, and state restoration
tags: arch, swiftui, routing, hashable, codable, type-safety
---

## Define Routes as Hashable Enums

A single Hashable + Codable enum for all routes provides compile-time safety for every navigation path in the app. The compiler enforces exhaustive switch handling so adding a new screen cannot be forgotten. Codable conformance enables NavigationPath serialization for state restoration and process termination recovery. Centralizing routes also makes deep linking a simple URL-to-enum mapping instead of scattered conditional logic.

**Incorrect (untyped string-based or boolean-based navigation):**

```swift
// COST: Zero compile-time safety, typos cause silent failures
// No Codable support, no state restoration
struct MainView: View {
    @State private var activeScreen: String? = nil
    @State private var showSettings = false
    @State private var showProfile = false
    var body: some View {
        NavigationStack {
            VStack {
                Button("Products") { activeScreen = "products" }
                Button("Settings") { showSettings = true }
            }
            .navigationDestination(isPresented: Binding(
                get: { activeScreen == "prodcts" }, // Typo — silent failure
                set: { if !$0 { activeScreen = nil } }
            )) {
                ProductListView()
            }
        }
    }
}
```

**Correct (Hashable + Codable route enum with associated values):**

```swift
// BENEFIT: Exhaustive switch handling, typed payloads, state restoration
enum AppRoute: Hashable, Codable {
    case productList(categoryId: String)
    case productDetail(productId: String)
    case sellerProfile(sellerId: String)
    case checkout(cartId: String)
    case settings
    case search(query: String)
    init?(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return nil }
        let pathSegments = components.path.split(separator: "/").map(String.init)
        switch (host, pathSegments.first) {
        case ("products", let productId?): self = .productDetail(productId: productId)
        case ("sellers", let sellerId?): self = .sellerProfile(sellerId: sellerId)
        case ("search", _):
            let query = components.queryItems?.first(where: { $0.name == "q" })?.value ?? ""
            self = .search(query: query)
        default: return nil
        }
    }
}

// Coordinator owns the typed route array — see arch-coordinator for full pattern
@Observable @MainActor
final class AppCoordinator {
    var path: [AppRoute] = []
    func navigate(to route: AppRoute) { path.append(route) }
    func popToRoot() { path.removeAll() }

    @ViewBuilder
    func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .productList(let categoryId): ProductListView(categoryId: categoryId)
        case .productDetail(let productId): ProductDetailView(productId: productId)
        case .sellerProfile(let sellerId): SellerProfileView(sellerId: sellerId)
        case .checkout(let cartId): CheckoutView(cartId: cartId)
        case .settings: SettingsView()
        case .search(let query): SearchResultsView(query: query)
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
