---
title: Design Tab Bars for Top-Level Navigation
impact: CRITICAL
impactDescription: tab bars reduce navigation taps by 60-80% compared to hamburger menus — users reach any section in 1 tap
tags: nav, tab-bar, navigation, flat, sections
---

## Design Tab Bars for Top-Level Navigation

Tab bars provide instant access to top-level sections. Use a tab bar for apps with 3-5 equally important sections. Each tab should represent a distinct category of content, not an action.

**Incorrect (misused tab bar):**

```swift
// Too many tabs, actions mixed with navigation
TabView {
    HomeView().tabItem { Label("Home", systemImage: "house") }
    SearchView().tabItem { Label("Search", systemImage: "magnifyingglass") }
    AddView().tabItem { Label("Add", systemImage: "plus.circle") } // action, not a section
    FavoritesView().tabItem { Label("Favorites", systemImage: "heart") }
    ProfileView().tabItem { Label("Profile", systemImage: "person") }
    SettingsView().tabItem { Label("Settings", systemImage: "gear") } // 6th tab overflows
}
```

**Correct (focused tab bar with distinct sections):**

```swift
TabView {
    HomeView()
        .tabItem { Label("Home", systemImage: "house") }
    SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
    FavoritesView()
        .tabItem { Label("Favorites", systemImage: "heart") }
    ProfileView()
        .tabItem { Label("Profile", systemImage: "person") }
}
// Actions like "Add" belong in toolbars, not tabs
```

**Tab bar guidelines:**
- Maximum 5 tabs on iPhone
- Each tab is a section, not an action
- Always show icon + label (never icon-only)
- Use SF Symbols that match Apple's weight conventions
- Preserve tab state when switching between tabs

Reference: [Tab bars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
