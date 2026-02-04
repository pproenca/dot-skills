---
title: Use Tab Bar for Top-Level Navigation
impact: CRITICAL
impactDescription: provides familiar iOS navigation pattern for main app sections
tags: nav, tab-bar, structure, primary-navigation
---

## Use Tab Bar for Top-Level Navigation

Use a tab bar for switching between 3-5 top-level sections of your app. Tab bars appear at the bottom of the screen and provide single-tap access to main areas.

**Incorrect (misusing tab bars):**

```swift
// Too many tabs - overwhelming
TabView {
    HomeView().tabItem { Label("Home", systemImage: "house") }
    SearchView().tabItem { Label("Search", systemImage: "magnifyingglass") }
    FavoritesView().tabItem { Label("Favorites", systemImage: "heart") }
    CartView().tabItem { Label("Cart", systemImage: "cart") }
    NotificationsView().tabItem { Label("Alerts", systemImage: "bell") }
    ProfileView().tabItem { Label("Profile", systemImage: "person") }
    SettingsView().tabItem { Label("Settings", systemImage: "gear") }
} // 7 tabs is too many

// Using tab bar for actions instead of navigation
TabView {
    // ...
    Button("Share") { }.tabItem { Label("Share", systemImage: "square.and.arrow.up") }
} // Tab bar is for navigation, not actions
```

**Correct (focused top-level navigation):**

```swift
TabView {
    NavigationStack {
        HomeView()
    }
    .tabItem {
        Label("Home", systemImage: "house")
    }

    NavigationStack {
        SearchView()
    }
    .tabItem {
        Label("Search", systemImage: "magnifyingglass")
    }

    NavigationStack {
        FavoritesView()
    }
    .tabItem {
        Label("Favorites", systemImage: "heart")
    }

    NavigationStack {
        ProfileView()
    }
    .tabItem {
        Label("Profile", systemImage: "person")
    }
}
```

**Tab bar best practices:**
- 3-5 tabs maximum
- Each tab has its own navigation stack
- Use `.fill` variant of SF Symbols for selected state
- Keep labels short (one word preferred)
- Tab bar is for navigation, never for actions

Reference: [Tab bars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
