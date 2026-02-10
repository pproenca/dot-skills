---
title: Use NavigationStack for Hierarchical Navigation
impact: CRITICAL
impactDescription: NavigationView deprecated in iOS 16+ — NavigationStack reduces navigation boilerplate by 40-60% with type-safe programmatic routing
tags: nav, navigation-stack, hierarchy, drill-down, push
---

## Use NavigationStack for Hierarchical Navigation

NavigationStack (iOS 16+) replaces NavigationView for drill-down navigation. It supports programmatic navigation via NavigationPath, type-safe destinations, and deep linking. NavigationView is deprecated.

**Incorrect (deprecated NavigationView):**

```swift
// NavigationView is deprecated in iOS 16+
NavigationView {
    List(items) { item in
        NavigationLink(destination: DetailView(item: item)) {
            ItemRow(item: item)
        }
    }
    .navigationTitle("Items")
}
```

**Correct (NavigationStack with type-safe destinations):**

```swift
struct ItemListView: View {
    @State private var path = NavigationPath()
    let items: [Item]

    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
        }
    }
}
```

**Programmatic navigation for deep linking:**

```swift
// Push screens programmatically
Button("Go to Settings") {
    path.append(Route.settings)
}

// Pop to root
Button("Back to Home") {
    path.removeLast(path.count)
}
```

**When to use NavigationStack vs NavigationSplitView:**
- NavigationStack: iPhone-first, single-column drill-down
- NavigationSplitView: iPad/Mac, multi-column sidebar + detail

Reference: [Navigation - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
