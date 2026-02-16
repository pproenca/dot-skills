---
title: Avoid Defining NavigationPath at App Level
impact: MEDIUM
impactDescription: breaks multi-scene support on iPad, prevents proper per-window state
tags: state, app-level, scene, multi-window, navigation-path
---

## Avoid Defining NavigationPath at App Level

Defining `NavigationPath` in the `@main App` struct means all scenes (windows) share the same navigation stack. On iPad with Stage Manager or Split View, navigating in one window changes navigation in all windows. Each `Scene` should own its own navigation path via `@SceneStorage` or `@State` inside the scene's root view. This enables proper multi-window support and correct state restoration per window.

**Incorrect (NavigationPath defined at App level — shared across all windows):**

```swift
@main
struct MyShopApp: App {
    // BAD: @State in App struct shared across ALL scenes
    // iPad Stage Manager: navigating Window A pushes onto Window B's stack
    @State private var navigationPath = NavigationPath()
    // NOTE: ObservableObject/@Published are legacy — use @Observable
    @StateObject private var router = AppRouter()
    var body: some Scene {
        WindowGroup {
            ContentView(path: $navigationPath, router: router)
        }
    }
}

struct ContentView: View {
    @Binding var path: NavigationPath
    @ObservedObject var router: AppRouter
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    route.destination
                }
        }
    }
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    func navigateToProduct(_ id: String) {
        path.append(Route.product(id: id)) // BAD: navigates ALL windows
    }
}
```

**Correct (@Observable coordinator owned per scene — each window gets its own instance):**

```swift
@Observable @MainActor
final class SceneCoordinator {
    var path = NavigationPath()
    func navigate(to route: Route) { path.append(route) }
    func popToRoot() { path = NavigationPath() }

    func saveState() -> Data? {
        try? JSONEncoder().encode(path.codable)
    }
    func restoreState(from data: Data) {
        guard let codable = try? JSONDecoder().decode(
            NavigationPath.CodableRepresentation.self, from: data
        ) else { return }
        path = NavigationPath(codable)
    }
}

@main
struct MyShopApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

@Equatable
struct ContentView: View {
    @State private var coordinator = SceneCoordinator()
    @SceneStorage("navigation") private var pathData: Data?

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .product(let id): ProductView(productId: id)
                    case .category(let slug): CategoryView(slug: slug)
                    case .order(let id): OrderView(orderId: id)
                    case .settings: SettingsView()
                    }
                }
        }
        .environment(coordinator)
        .onChange(of: coordinator.path) { _, newPath in
            pathData = coordinator.saveState()
        }
        .task {
            guard let data = pathData else { return }
            coordinator.restoreState(from: data)
        }
        .onOpenURL { url in
            guard let routes = Route.fromURL(url) else { return }
            coordinator.popToRoot()
            for route in routes { coordinator.navigate(to: route) }
        }
    }
}
```
