---
title: Use TabView for Top-Level Sections
impact: HIGH
impactDescription: standard iOS navigation pattern, persistent tabs, independent navigation stacks
tags: nav, swiftui, navigation, tabview, tabs, organization
---

## Use TabView for Top-Level Sections

`TabView` organizes your app into distinct sections with tabs at the bottom. Each tab maintains its own navigation state. Use tab items with SF Symbols for consistent iOS appearance.

**Incorrect (manual tab implementation):**

```swift
// Don't build custom tab bars
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            if selectedTab == 0 {
                FriendsView()
            } else {
                MoviesView()
            }
            HStack {
                Button("Friends") { selectedTab = 0 }
                Button("Movies") { selectedTab = 1 }
            }
        }
    }
}
```

**Correct (TabView with proper tab items):**

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FriendListView()
            }
            .tabItem {
                Label("Friends", systemImage: "person.2")
            }

            NavigationStack {
                MovieListView()
            }
            .tabItem {
                Label("Movies", systemImage: "film")
            }
        }
    }
}

// With programmatic selection
struct ContentView: View {
    @State private var selectedTab = Tab.friends

    var body: some View {
        TabView(selection: $selectedTab) {
            FriendListView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(Tab.friends)

            MovieListView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
                .tag(Tab.movies)
        }
    }

    enum Tab {
        case friends, movies
    }
}
```

**TabView best practices:**
- Wrap each tab's content in NavigationStack
- Use SF Symbols for tab icons
- Keep to 5 or fewer tabs (iOS guideline)
- Use `tag` and `selection` for programmatic control

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
