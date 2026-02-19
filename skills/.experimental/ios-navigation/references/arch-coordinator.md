---
title: Extract Navigation Logic into Observable Coordinator
impact: CRITICAL
impactDescription: reduces navigation-related bugs by 60-80% — centralizes all navigation state into one testable object, enabling deep linking and unit-testable flows without UI tests
tags: arch, swiftui, coordinator, observable, testing, separation-of-concerns
---

## Extract Navigation Logic into Observable Coordinator

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Every feature MUST have a coordinator. When navigation state is scattered across views with @State properties, it becomes impossible to unit test navigation flows, handle deep links centrally, or coordinate complex multi-step transitions like authentication gates or onboarding flows. An @Observable coordinator centralizes all navigation state (stack path, presented sheets, full-screen covers, alerts) into a single testable object. Views become pure renderers of coordinator state, and navigation logic can be verified without UI tests.

**Incorrect (navigation state scattered across multiple views):**

```swift
// COST: Navigation state spread across views, no central control
// Deep linking requires reaching into each view's @State
// Testing navigation flows impossible without UI tests
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
// All navigation state in one testable object
@Observable @MainActor
final class AppCoordinator {
    var path: [AppRoute] = []
    var presentedSheet: SheetDestination?
    var presentedFullScreenCover: FullScreenCoverDestination?
    private let authService: AuthServiceProtocol
    init(authService: AuthServiceProtocol = AuthService.shared) { self.authService = authService }
    func navigate(to route: AppRoute) { path.append(route) }
    func pop() { guard !path.isEmpty else { return }; path.removeLast() }
    func popToRoot() { path.removeAll() }
    func showSettings() { presentedSheet = .settings }
    func showProfile() {
        guard authService.isLoggedIn else {
            presentedSheet = .login(returnAction: .profile); return
        }
        presentedSheet = .profile
    }
    func showPurchaseConfirmation(orderId: String) {
        presentedFullScreenCover = .purchaseConfirmation(orderId: orderId)
    }
    func handleDeepLink(_ url: URL) {
        guard let route = AppRoute(from: url) else { return }
        popToRoot(); navigate(to: route)
    }
    func saveState() -> Data? { try? JSONEncoder().encode(path) }
    func restoreState(from data: Data) {
        path = (try? JSONDecoder().decode([AppRoute].self, from: data)) ?? []
    }
}

@Equatable
struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            ProductGrid()
                .navigationDestination(for: AppRoute.self) { route in
                    /* ... switch route cases ... */
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheetContent(for: $0) }
        .fullScreenCover(item: $coordinator.presentedFullScreenCover) { fullScreenContent(for: $0) }
        .onOpenURL { coordinator.handleDeepLink($0) }
    }
}
```
