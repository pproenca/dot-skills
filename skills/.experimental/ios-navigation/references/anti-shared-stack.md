---
title: Avoid Sharing NavigationStack Across Tabs
impact: CRITICAL
impactDescription: navigation state bleeds between tabs, back stack corruption
tags: anti, tab-view, navigation-stack, state-bleed
---

## Avoid Sharing NavigationStack Across Tabs

Each tab must own its own `NavigationStack` with an independent navigation path. Wrapping an entire `TabView` in a single `NavigationStack` causes pushes in one tab to remain visible when switching tabs, the back button to appear on unrelated tabs, and `popToRoot` to affect the wrong content. Apple explicitly warns against this pattern in the Human Interface Guidelines.

**Incorrect (single NavigationStack wrapping TabView):**

```swift
// BAD: One stack for all tabs. Pushing a detail in the
// Home tab leaves the back button visible when the user
// switches to Profile. The navigation bar title shows
// "Home Detail" on the Profile tab. State is fully corrupted.
struct AppRootView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {          // Shared stack — every tab shares this
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)

                SearchView()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(1)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(2)
            }
        }
    }
}
```

**Correct (each tab owns its NavigationStack):**

```swift
// GOOD: Independent stacks per tab. Each tab has its own
// back stack, path state, and navigation bar configuration.
// Switching tabs preserves each tab's navigation history.
struct AppRootView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(1)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person") }
            .tag(2)
        }
    }
}
```
