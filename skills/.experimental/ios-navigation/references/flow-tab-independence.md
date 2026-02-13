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

**Correct (each tab owns its own NavigationStack):**

```swift
// GOOD: Each tab manages its own NavigationStack and path —
// tab switches preserve per-tab navigation history
struct MainView: View {
    // Independent path arrays — no cross-tab state bleed
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                // Home tab has its own stack and back history
                NavigationStack(path: $homePath) {
                    HomeView()
                        .navigationDestination(for: HomeRoute.self) { route in
                            HomeDetailView(route: route)
                        }
                }
            }
            Tab("Search", systemImage: "magnifyingglass") {
                // Search tab preserves drill-down state independently
                NavigationStack(path: $searchPath) {
                    SearchView()
                        .navigationDestination(for: SearchRoute.self) { route in
                            SearchResultView(route: route)
                        }
                }
            }
            Tab("Profile", systemImage: "person") {
                // Profile tab maintains its own navigation depth
                NavigationStack(path: $profilePath) {
                    ProfileView()
                        .navigationDestination(for: ProfileRoute.self) { route in
                            ProfileDetailView(route: route)
                        }
                }
            }
        }
    }
}
```
