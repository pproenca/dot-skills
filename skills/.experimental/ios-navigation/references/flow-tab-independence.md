---
title: Give Each Tab Its Own NavigationStack
impact: HIGH
impactDescription: prevents cross-tab state bleed, preserves per-tab back stack
tags: flow, tab-view, navigation-stack, independence
---

## Give Each Tab Its Own NavigationStack

Each tab must own its own NavigationStack with an independent navigation path array. When a single NavigationStack wraps the entire TabView, switching tabs loses the previous tab's navigation history and can cause routes from one tab to bleed into another. Independent stacks ensure each tab maintains its own back stack across tab switches.

**Incorrect (shared stack wrapping TabView):**

```swift
// BAD: One NavigationStack for all tabs — switching tabs resets
// the navigation history and routes leak between contexts
struct MainView: View {
    @State private var path = NavigationPath()

    var body: some View {
        // Wrapping TabView in a single stack means all tabs
        // share the same back stack — tab switches wipe history
        NavigationStack(path: $path) {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                Tab("Search", systemImage: "magnifyingglass") {
                    SearchView()
                }
                Tab("Profile", systemImage: "person") {
                    ProfileView()
                }
            }
        }
    }
}
```

**Correct (each tab owns its own coordinator and NavigationStack):**

```swift
// Each tab gets its own coordinator — no cross-tab state bleed
@Observable @MainActor
final class HomeCoordinator {
    var path = NavigationPath()
    func navigate(to route: HomeRoute) { path.append(route) }
    func popToRoot() { path = NavigationPath() }
}

@Observable @MainActor
final class SearchCoordinator {
    var path = NavigationPath()
    func navigate(to route: SearchRoute) { path.append(route) }
    func popToRoot() { path = NavigationPath() }
}

@Observable @MainActor
final class ProfileCoordinator {
    var path = NavigationPath()
    func navigate(to route: ProfileRoute) { path.append(route) }
    func popToRoot() { path = NavigationPath() }
}

// GOOD: Each tab manages its own coordinator and NavigationStack —
// tab switches preserve per-tab navigation history
@Equatable
struct MainView: View {
    @State private var homeCoordinator = HomeCoordinator()
    @State private var searchCoordinator = SearchCoordinator()
    @State private var profileCoordinator = ProfileCoordinator()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                @Bindable var coordinator = homeCoordinator
                NavigationStack(path: $coordinator.path) {
                    HomeView()
                        .navigationDestination(for: HomeRoute.self) { route in
                            HomeDetailView(route: route)
                        }
                }
                .environment(homeCoordinator)
            }
            Tab("Search", systemImage: "magnifyingglass") {
                @Bindable var coordinator = searchCoordinator
                NavigationStack(path: $coordinator.path) {
                    SearchView()
                        .navigationDestination(for: SearchRoute.self) { route in
                            SearchResultView(route: route)
                        }
                }
                .environment(searchCoordinator)
            }
            Tab("Profile", systemImage: "person") {
                @Bindable var coordinator = profileCoordinator
                NavigationStack(path: $coordinator.path) {
                    ProfileView()
                        .navigationDestination(for: ProfileRoute.self) { route in
                            ProfileDetailView(route: route)
                        }
                }
                .environment(profileCoordinator)
            }
        }
    }
}
```
