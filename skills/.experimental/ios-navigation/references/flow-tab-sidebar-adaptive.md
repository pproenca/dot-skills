---
title: Use sidebarAdaptable TabView for iPad Tab-to-Sidebar (iOS 18+)
impact: MEDIUM-HIGH
impactDescription: automatic tab bar on iPhone, sidebar on iPad with zero extra code
tags: flow, tab-view, sidebar, adaptive, ios18
---

## Use sidebarAdaptable TabView for iPad Tab-to-Sidebar (iOS 18+)

iOS 18+ TabView with `.tabViewStyle(.sidebarAdaptable)` automatically converts the tab bar into a sidebar on iPad, giving users a richer navigation surface on larger screens while keeping the familiar tab bar on iPhone. Writing separate TabView and NavigationSplitView implementations with device-checking logic doubles maintenance, introduces layout bugs across size classes, and breaks when Apple ships new form factors.

**Incorrect (separate implementations with device checks):**

```swift
// BAD: Two completely separate navigation hierarchies maintained
// in parallel — double the code, double the bugs
struct AdaptiveRootView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        // Device-specific branching that must be kept in sync —
        // any new tab added must be duplicated in both branches
        if sizeClass == .regular {
            NavigationSplitView {
                List {
                    NavigationLink("Home", destination: HomeView())
                    NavigationLink("Search", destination: SearchView())
                    NavigationLink("Settings", destination: SettingsView())
                }
            } detail: {
                HomeView()
            }
        } else {
            TabView {
                Tab("Home", systemImage: "house") { HomeView() }
                Tab("Search", systemImage: "magnifyingglass") { SearchView() }
                Tab("Settings", systemImage: "gear") { SettingsView() }
            }
        }
    }
}
```

**Correct (sidebarAdaptable TabView with TabSection grouping):**

```swift
// GOOD: Single TabView definition — tab bar on iPhone, sidebar on iPad,
// with user-customizable tab ordering persisted automatically
struct AdaptiveRootView: View {
    // Apple manages persistence automatically when tabs have .customizationID()
    @State private var customization = TabViewCustomization()

    var body: some View {
        TabView {
            // Primary tabs appear in both tab bar and sidebar
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView()
                }
            }
            .customizationID("home")

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchView()
                }
            }
            .customizationID("search")

            Tab("Favorites", systemImage: "heart") {
                NavigationStack {
                    FavoritesView()
                }
            }
            .customizationID("favorites")

            // TabSection groups items in the sidebar —
            // on iPhone these remain individual tabs
            TabSection("Account") {
                Tab("Profile", systemImage: "person") {
                    NavigationStack {
                        ProfileView()
                    }
                }
                .customizationID("profile")

                Tab("Settings", systemImage: "gear") {
                    NavigationStack {
                        SettingsView()
                    }
                }
                .customizationID("settings")
            }
        }
        // Single modifier — iPhone gets tab bar, iPad gets sidebar
        .tabViewStyle(.sidebarAdaptable)
        // Enables drag-to-reorder and user tab customization
        .tabViewCustomization($customization)
    }
}
```
