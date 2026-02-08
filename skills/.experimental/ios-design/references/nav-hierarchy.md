---
title: Design Clear Navigation Hierarchy
impact: HIGH
impactDescription: helps users understand where they are and how to navigate
tags: nav, hierarchy, information-architecture, wayfinding
---

## Design Clear Navigation Hierarchy

Structure your app with a clear hierarchy: hub screens lead to list screens, which lead to detail screens. Users should always know where they are and how to get back.

**Incorrect (confusing navigation structure):**

```swift
// Random jumping between unrelated screens
Button("Go to Settings") {
    // From detail view, jump to settings
    showSettings = true
}
// User loses their place in the hierarchy

// Multiple entry points to same content
// Detail accessible from 3 different lists without clear context
```

**Correct (clear hierarchical flow):**

```swift
// Hub -> List -> Detail pattern
NavigationStack {
    // Hub screen
    List {
        NavigationLink("Recent Orders", value: Route.ordersList)
        NavigationLink("Favorites", value: Route.favoritesList)
        NavigationLink("Settings", value: Route.settings)
    }
    .navigationTitle("Home")
    .navigationDestination(for: Route.self) { route in
        switch route {
        case .ordersList:
            OrdersListView()
        case .favoritesList:
            FavoritesListView()
        case .settings:
            SettingsView()
        }
    }
}

// Each list leads to its own details
struct OrdersListView: View {
    var body: some View {
        List(orders) { order in
            NavigationLink(value: order) {
                OrderRow(order: order)
            }
        }
        .navigationTitle("Orders")
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }
}
```

**Hierarchy principles:**
- Maximum 3-4 levels deep before users feel lost
- Each screen should have one clear parent
- Use breadcrumb-style back button labels
- Modals for tasks, not navigation
- Tab bar sections are parallel, not hierarchical

Reference: [Navigation and search - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
