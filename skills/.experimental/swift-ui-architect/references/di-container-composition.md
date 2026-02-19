---
title: Compose Dependency Container at App Root
impact: MEDIUM
impactDescription: reduces dependency wiring bugs to O(1) location vs O(N) scattered creation points
tags: di, container, composition-root, app-root, lifecycle
---

## Compose Dependency Container at App Root

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

All live dependencies are created and composed at the `App` struct level (`@main`). This is the "composition root" — the single place where concrete implementations are wired together. Feature modules only know about protocols. This pattern makes the dependency graph explicit, prevents hidden singletons, and ensures proper lifecycle management through SwiftUI's state system.

**Incorrect (ViewModels creating their own dependencies — hidden composition, duplicated instances):**

```swift
// Each ViewModel creates its own dependencies internally
@Observable
class ProfileViewModel {
    // Hidden dependency creation — not visible to callers
    private let networkService = NetworkService()
    private let userRepository = UserRepository(
        networkService: NetworkService()  // ANOTHER instance — duplicated!
    )
    private let analyticsService = AnalyticsService.shared  // hidden singleton

    func loadProfile() async {
        let user = try? await userRepository.fetchCurrentUser()
        analyticsService.track(.profileViewed)
    }
}

@Observable
class SettingsViewModel {
    // Same dependencies created AGAIN — different instances, no shared state
    private let userRepository = UserRepository(
        networkService: NetworkService()
    )
    private let analyticsService = AnalyticsService.shared

    func updateSettings() async {
        // This userRepository has a DIFFERENT cache than ProfileViewModel's
    }
}

// App struct has no visibility into what dependencies exist
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()  // no idea what's happening inside
        }
    }
}
```

**Correct (composition root at @main — all dependencies created and injected once):**

```swift
// Dependency container holds all live implementations
@Observable
class AppDependencies {
    let networkService: any NetworkServiceProtocol
    let userRepository: any UserRepositoryProtocol
    let analyticsService: any AnalyticsServiceProtocol
    let settingsRepository: any SettingsRepositoryProtocol

    init() {
        // Single creation point — shared instances, explicit wiring
        let network = NetworkService(baseURL: Config.apiBaseURL)
        self.networkService = network
        self.userRepository = UserRepository(networkService: network)
        self.analyticsService = AnalyticsService(apiKey: Config.analyticsKey)
        self.settingsRepository = SettingsRepository(networkService: network)
    }
}

// App struct is the composition root — injects everything
@main
struct MyApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(\.networkService, dependencies.networkService)
                .environment(\.userRepository, dependencies.userRepository)
                .environment(\.analyticsService, dependencies.analyticsService)
                .environment(\.settingsRepository, dependencies.settingsRepository)
        }
    }
}

// ViewModels receive dependencies — never create them
@Observable
class ProfileViewModel {
    private let userRepository: any UserRepositoryProtocol
    private let analyticsService: any AnalyticsServiceProtocol

    init(
        userRepository: any UserRepositoryProtocol,
        analyticsService: any AnalyticsServiceProtocol
    ) {
        self.userRepository = userRepository
        self.analyticsService = analyticsService
    }
}
```

**Key benefits:**
- Entire dependency graph is visible in one place
- Shared instances (e.g., `networkService`) are created once and reused
- Swapping implementations (e.g., for staging/production) is a single-line change
- No hidden singletons — everything flows through the composition root

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
