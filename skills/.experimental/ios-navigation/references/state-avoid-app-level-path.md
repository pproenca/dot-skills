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
    // BAD: @State in App struct is shared across ALL scenes.
    // iPad Stage Manager: user opens two windows of the app.
    // Navigating in Window A pushes onto Window B's stack too.
    @State private var navigationPath = NavigationPath()

    // BAD: @StateObject in App struct has the same problem.
    // One router instance, shared across all windows.
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            // Both windows receive the same Binding<NavigationPath>.
            // Push in Window A -> Window B shows the same destination.
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

    // BAD: This navigates ALL windows to the product.
    func navigateToProduct(_ id: String) {
        path.append(Route.product(id: id))
    }
}
```

**Correct (NavigationPath owned per scene in the root view):**

```swift
@main
struct MyShopApp: App {
    // App struct contains NO navigation state.
    // Each scene manages its own navigation independently.
    var body: some Scene {
        WindowGroup {
            // Each window gets its own ContentView instance
            // with its own @State and @SceneStorage.
            ContentView()
        }
    }
}

struct ContentView: View {
    // @State: each scene instance gets its own NavigationPath.
    // iPad Window A and Window B navigate independently.
    @State private var path = NavigationPath()

    // @SceneStorage: persists per scene, not globally.
    // Each window restores its own navigation history.
    @SceneStorage("navigation") private var pathData: Data?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .product(let id):
                        ProductView(productId: id)
                    case .category(let slug):
                        CategoryView(slug: slug)
                    case .order(let id):
                        OrderView(orderId: id)
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .onChange(of: path) { newPath in
            // Saves only THIS window's navigation path.
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
        .task {
            // Restores only THIS window's navigation path.
            guard let data = pathData,
                  let codable = try? JSONDecoder().decode(
                      NavigationPath.CodableRepresentation.self,
                      from: data
                  ) else { return }
            path = NavigationPath(codable)
        }
        .onOpenURL { url in
            // Deep link navigates only THIS window.
            guard let routes = Route.fromURL(url) else { return }
            path = NavigationPath()
            for route in routes {
                path.append(route)
            }
        }
    }
}

// If you need a router pattern, make it per-scene:
struct ContentViewWithRouter: View {
    // @StateObject: each scene creates its own router instance.
    @StateObject private var router = SceneRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    route.destination
                }
        }
        // Pass router to child views that need programmatic navigation.
        .environmentObject(router)
    }
}

class SceneRouter: ObservableObject {
    @Published var path = NavigationPath()

    // Navigates only the scene that owns this router.
    func navigate(to route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
```
