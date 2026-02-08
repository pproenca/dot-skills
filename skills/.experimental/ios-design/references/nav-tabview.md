---
title: Organize App Sections with TabView
impact: HIGH
impactDescription: provides familiar iOS navigation pattern for top-level sections
tags: nav, tabview, tabs, organization, structure
---

## Organize App Sections with TabView

TabView provides the familiar iOS tab bar for switching between top-level app sections. Each tab maintains its own navigation state.

**Incorrect (tabs without proper structure):**

```swift
struct AppView: View {
    var body: some View {
        TabView {
            HomeView()  // No tab item
            SearchView()
            ProfileView()
        }
    }
}
```

**Correct (properly configured tabs):**

```swift
struct AppView: View {
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
}

enum Tab: Hashable {
    case home, search, profile
}
```

**Tab badge for notifications:**

```swift
.tabItem {
    Label("Inbox", systemImage: "envelope")
}
.badge(unreadCount)  // Shows red badge
```

**Guidelines for tabs:**
- Use 3-5 tabs (more requires "More" tab)
- Each tab is a self-contained section
- Tabs should represent parallel content, not sequential flow
- Use SF Symbols for consistency
- Tab labels should be short (1-2 words)

**Programmatic tab switching:**

```swift
// Switch to search tab
selectedTab = .search

// Handle deep links
.onOpenURL { url in
    if url.path.contains("profile") {
        selectedTab = .profile
    }
}
```

Reference: [Human Interface Guidelines - Tab Bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
