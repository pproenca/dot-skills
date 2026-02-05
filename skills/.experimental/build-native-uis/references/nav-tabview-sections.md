---
title: Use TabView for Top-Level App Sections
impact: HIGH
impactDescription: standard iOS navigation pattern for parallel content areas
tags: nav, tabview, tabs, app-structure, ios
---

## Use TabView for Top-Level App Sections

TabView is the standard iOS pattern for switching between independent top-level sections. Building a custom tab bar loses platform-native behavior like badge support, accessibility labels, and adaptive layout on iPad. SwiftUI's TabView handles all of this automatically.

**Incorrect (building a custom tab bar manually):**

```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case 0: HomeView()
            case 1: SearchView()
            case 2: ProfileView()
            default: HomeView()
            }
            HStack { // custom tab bar loses native behavior
                Button { selectedTab = 0 } label: {
                    Label("Home", systemImage: "house")
                }
                Button { selectedTab = 1 } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                Button { selectedTab = 2 } label: {
                    Label("Profile", systemImage: "person")
                }
            }
            .padding()
        }
    }
}
```

**Correct (using TabView with Tab items):**

```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) { // native tab bar with full platform support
            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                SearchView()
            }
            Tab("Profile", systemImage: "person", value: 2) {
                ProfileView()
            }
        }
    }
}
```

**Note:** The `Tab` initializer with `value:` requires iOS 18+. For iOS 17 targets, use `.tabItem { Label("Home", systemImage: "house") }` on each view inside `TabView`.

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
