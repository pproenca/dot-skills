---
title: Use NavigationStack for Programmatic, Type-Safe Navigation
impact: CRITICAL
impactDescription: NavigationView is deprecated and lacks programmatic path control — NavigationStack enables deep linking, state restoration, and complex navigation flows that NavigationView cannot support
tags: converse, navigation, stack, kocienda-demo, edson-conversation, ios16
---

## Use NavigationStack for Programmatic, Type-Safe Navigation

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Edson's conversation principle means navigation should be a clear dialogue between user and app. `NavigationStack` (iOS 16+) makes this conversation programmatic — the app can say "let me take you to this specific place" through path manipulation, and the user can say "take me back" through the system back gesture. Kocienda's demo culture demanded interfaces that could be navigated to any state instantly for a demo — programmatic navigation enables exactly that.

**Incorrect (deprecated NavigationView with limited control):**

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            List(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    ItemRow(item: item)
                }
            }
        }
    }
}
```

**Correct (NavigationStack with programmatic path):**

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
.navigationBarTitleDisplayMode(.large)      // Large scrollable title
.navigationBarTitleDisplayMode(.inline)     // Small centered title
.navigationBarTitleDisplayMode(.automatic)  // Context-dependent
```

**When NOT to use NavigationStack:** Inside a tab that already has its own NavigationStack. Each tab should own its own navigation stack; don't nest stacks.

Reference: [NavigationStack - Apple Documentation](https://developer.apple.com/documentation/swiftui/navigationstack)
