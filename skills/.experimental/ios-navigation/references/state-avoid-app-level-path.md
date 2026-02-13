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

**Correct (NavigationPath owned per scene in the root view):**

```swift
@main
struct MyShopApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
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
                    case .product(let id): ProductView(productId: id)
                    case .category(let slug): CategoryView(slug: slug)
                    case .order(let id): OrderView(orderId: id)
                    case .settings: SettingsView()
                    }
                }
        }
        .onChange(of: path) { newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
        .task {
            guard let data = pathData,
                  let codable = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data)
            else { return }
            path = NavigationPath(codable)
        }
        .onOpenURL { url in
            guard let routes = Route.fromURL(url) else { return }
            path = NavigationPath(); for route in routes { path.append(route) }
        }
    }
}
// Router pattern per-scene (each scene gets its own instance)
@Observable class SceneRouter {
    var path = NavigationPath()
    func navigate(to route: Route) { path.append(route) }
}

struct ContentViewWithRouter: View {
    @State private var router = SceneRouter()
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            HomeView().navigationDestination(for: Route.self) { $0.destination }
        }.environment(router)
    }
}
```
