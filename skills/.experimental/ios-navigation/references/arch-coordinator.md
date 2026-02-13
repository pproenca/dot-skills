---
title: Extract Navigation Logic into Observable Coordinator
impact: HIGH
impactDescription: enables testable navigation, deep linking, and separation of concerns
tags: arch, swiftui, coordinator, observable, testing, separation-of-concerns
---

## Extract Navigation Logic into Observable Coordinator

When navigation state is scattered across views with @State properties, it becomes impossible to unit test navigation flows, handle deep links centrally, or coordinate complex multi-step transitions like authentication gates or onboarding flows. An @Observable coordinator centralizes all navigation state (stack path, presented sheets, full-screen covers, alerts) into a single testable object. Views become pure renderers of coordinator state, and navigation logic can be verified without UI tests.

**Incorrect (navigation state scattered across multiple views):**

```swift
// COST: Navigation state is spread across 4+ views with no central
// control. Deep linking requires reaching into each view's @State.
// Testing a navigation flow (e.g., login -> onboarding -> home) is
// impossible without UI tests. Adding an auth gate means modifying
// every view that can trigger navigation.
struct HomeView: View {
    @State private var showSettings = false
    @State private var showProfile = false
    @State private var selectedProduct: Product? = nil
    @State private var showPurchaseConfirmation = false
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                Button("Settings") { showSettings = true }
                Button("Profile") {
                    if AuthService.shared.isLoggedIn {
                        showProfile = true
                    } else {
                        showLoginSheet = true // Auth check duplicated everywhere
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showProfile) { ProfileView() }
            .sheet(isPresented: $showLoginSheet) { LoginView() }
            .fullScreenCover(isPresented: $showPurchaseConfirmation) {
                PurchaseConfirmationView()
            }
        }
    }
}
```

**Correct (@Observable coordinator centralizing all navigation state):**

```swift
// BENEFIT: All navigation state lives in one testable object. Deep
// links call coordinator methods. Auth gates are enforced in one place.
// Unit tests verify navigation flows without rendering any views.
@Observable
final class AppCoordinator {
    var path: [AppRoute] = []
    var presentedSheet: SheetDestination?
    var presentedFullScreenCover: FullScreenCoverDestination?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - Push Navigation

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    // MARK: - Modal Presentation

    func showSettings() {
        presentedSheet = .settings
    }

    func showProfile() {
        guard authService.isLoggedIn else {
            presentedSheet = .login(returnAction: .profile)
            return
        }
        presentedSheet = .profile
    }

    func showPurchaseConfirmation(orderId: String) {
        presentedFullScreenCover = .purchaseConfirmation(orderId: orderId)
    }

    // MARK: - Deep Linking

    func handleDeepLink(_ url: URL) {
        guard let route = AppRoute(from: url) else { return }
        popToRoot()
        navigate(to: route)
    }

    // MARK: - State Restoration

    func saveState() -> Data? {
        try? JSONEncoder().encode(path)
    }

    func restoreState(from data: Data) {
        path = (try? JSONDecoder().decode([AppRoute].self, from: data)) ?? []
    }
}

// View reads coordinator state, never owns navigation logic
struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            ProductGrid()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .productDetail(let id):
                        ProductDetailView(productId: id)
                    case .sellerProfile(let id):
                        SellerProfileView(sellerId: id)
                    case .checkout(let cartId):
                        CheckoutView(cartId: cartId)
                    default:
                        EmptyView()
                    }
                }
        }
        .sheet(item: $coordinator.presentedSheet) { destination in
            sheetContent(for: destination)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreenCover) { destination in
            fullScreenContent(for: destination)
        }
        .onOpenURL { url in
            coordinator.handleDeepLink(url)
        }
    }
}
```
