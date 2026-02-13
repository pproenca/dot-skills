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
// COST: String-based routing has zero compile-time safety. Typos cause
// silent navigation failures. Adding a new screen requires grep-hunting
// for string literals. No Codable support means no state restoration.
// Deep linking requires fragile string parsing at every call site.
struct MainView: View {
    @State private var activeScreen: String? = nil
    @State private var selectedProductId: String? = nil
    @State private var showSettings = false
    @State private var showProfile = false
    @State private var searchQuery: String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Button("Products") { activeScreen = "products" }
                Button("Settings") { showSettings = true }
                Button("Profile") { showProfile = true }
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
// BENEFIT: Compiler enforces exhaustive handling — adding a case forces
// updates everywhere. Associated values carry typed payloads. Codable
// enables NavigationPath serialization for state restoration. Deep
// linking maps URLs to enum cases in a single function.
enum AppRoute: Hashable, Codable {
    case productList(categoryId: String)
    case productDetail(productId: String)
    case sellerProfile(sellerId: String)
    case checkout(cartId: String)
    case orderConfirmation(orderId: String)
    case settings
    case search(query: String)

    /// Maps a universal link URL to a typed route.
    init?(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return nil }

        let pathSegments = components.path.split(separator: "/").map(String.init)

        switch (host, pathSegments.first) {
        case ("products", let productId?):
            self = .productDetail(productId: productId)
        case ("sellers", let sellerId?):
            self = .sellerProfile(sellerId: sellerId)
        case ("orders", let orderId?):
            self = .orderConfirmation(orderId: orderId)
        case ("search", _):
            let query = components.queryItems?.first(where: { $0.name == "q" })?.value ?? ""
            self = .search(query: query)
        default:
            return nil
        }
    }
}

// Usage with NavigationStack
struct AppRootView: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .productList(let categoryId):
                        ProductListView(categoryId: categoryId)
                    case .productDetail(let productId):
                        ProductDetailView(productId: productId)
                    case .sellerProfile(let sellerId):
                        SellerProfileView(sellerId: sellerId)
                    case .checkout(let cartId):
                        CheckoutView(cartId: cartId)
                    case .orderConfirmation(let orderId):
                        OrderConfirmationView(orderId: orderId)
                    case .settings:
                        SettingsView()
                    case .search(let query):
                        SearchResultsView(query: query)
                    }
                }
        }
    }
}
```
