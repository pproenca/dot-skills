---
title: Use NavigationStack for Modern Navigation
impact: HIGH
impactDescription: enables programmatic navigation and deep linking
tags: nav, navigationstack, navigation, routing, ios16
---

## Use NavigationStack for Modern Navigation

NavigationStack (iOS 16+) replaces NavigationView with programmatic path control. This enables deep linking, state restoration, and complex navigation flows.

**Incorrect (deprecated NavigationView):**

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {  // Deprecated, limited control
            List(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    ItemRow(item: item)
                }
            }
        }
    }
}
```

**Correct (NavigationStack with path):**

```swift
struct ContentView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationDestination(for: Category.self) { category in
                CategoryView(category: category)
            }
        }
    }

    // Programmatic navigation
    func navigateToItem(_ item: Item) {
        navigationPath.append(item)
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
```

**Deep linking support:**

```swift
struct AppView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: DeepLink.self) { link in
                    link.destination
                }
        }
        .onOpenURL { url in
            if let deepLink = DeepLink(url: url) {
                path.append(deepLink)
            }
        }
    }
}
```

**Navigation title styles:**

```swift
.navigationTitle("Inbox")
.navigationBarTitleDisplayMode(.large)   // Large title
.navigationBarTitleDisplayMode(.inline)  // Small title
.navigationBarTitleDisplayMode(.automatic) // Context-dependent
```

Reference: [NavigationStack - Apple Documentation](https://developer.apple.com/documentation/swiftui/navigationstack)
