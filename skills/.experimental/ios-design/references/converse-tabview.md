---
title: Organize App Sections with TabView for Parallel Navigation
impact: CRITICAL
impactDescription: without TabView, users must navigate back to root before switching contexts — TabView preserves each section's navigation state independently, eliminating 3-5 taps per context switch
tags: converse, tabview, tabs, kocienda-demo, edson-conversation, navigation
---

## Organize App Sections with TabView for Parallel Navigation

Edson's conversation principle recognizes that users have parallel conversations with different parts of an app — checking messages, browsing content, updating settings — and they expect to switch between these conversations without losing their place. TabView provides exactly this: each tab maintains its own navigation state. Kocienda's demo culture at Apple relied on being able to jump instantly between app sections; TabView makes this the default experience.

**Incorrect (manual navigation between top-level sections):**

```swift
struct AppView: View {
    @State private var currentSection = "Home"

    var body: some View {
        NavigationStack {
            switch currentSection {
            case "Home": HomeView()
            case "Search": SearchView()
            case "Profile": ProfileView()
            default: HomeView()
            }
        }
        // Switching sections resets navigation state
    }
}
```

**Correct (TabView with independent navigation per tab):**

```swift
struct AppView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchView()
                }
            }

            Tab("Favorites", systemImage: "heart.fill") {
                NavigationStack {
                    FavoritesView()
                }
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                }
            }
        }
    }
}
```

**Tab bar conventions:**
- 3-5 tabs maximum — more causes crowding and confusion
- Use SF Symbols for tab icons — they align with system tab bars
- Labels should be single words or very short phrases
- Each tab owns its own `NavigationStack` — never share stacks between tabs
- Tab order: most-used sections first, profile/settings last

**When NOT to use TabView:** Apps with a single primary flow (camera apps, media players, games) don't need tabs. Use tabs when the app has 3-5 genuinely parallel sections.

Reference: [Tab bars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
