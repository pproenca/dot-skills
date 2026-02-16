---
title: Use Tab Bar for Top-Level Section Navigation
impact: HIGH
impactDescription: system TabView cuts section-switch time to 1 tap (O(1)) vs 2-4 taps to navigate back to root with custom solutions — persistent tab bar eliminates 100% of "navigate back to switch" friction across 3-5 app sections
tags: converse, tab-bar, navigation, kocienda-demo, edson-conversation, orientation
---

## Use Tab Bar for Top-Level Section Navigation

Edson's conversation principle means the user should always know where they are and how to switch topics. The tab bar is a persistent anchor — it stays visible across all navigation levels within each tab, providing constant orientation. Kocienda's demo culture valued the ability to switch instantly between app sections during a live demo; the tab bar makes this possible.

**Incorrect (custom tab bar that disappears during navigation):**

```swift
struct AppView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            // Content
            switch selectedTab {
            case 0: HomeView()
            case 1: SearchView()
            default: ProfileView()
            }

            // Custom tab bar that disappears on push navigation
            HStack {
                ForEach(0..<3) { index in
                    Button { selectedTab = index } label: {
                        Image(systemName: tabIcon(index))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
}
```

**Correct (system TabView with persistent tab bar):**

```swift
struct AppView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                    // Tab bar stays visible during navigation
                }
            }

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchView()
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

**Tab bar best practices:**
- 3-5 tabs — fewer is better, never more than 5 on iPhone
- Each tab icon should be instantly recognizable as an SF Symbol
- Use `.badge()` for unread counts or notifications
- Tab labels should be single words (Home, Search, Profile — not "My Account Settings")
- First tab should be the app's primary experience

**When NOT to use tab bar:** Apps with a single linear flow (camera, media playback), apps with <3 sections (use a single NavigationStack instead), or immersive experiences (games, full-screen media).

Reference: [Tab bars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
