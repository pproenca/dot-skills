---
title: Manage Navigation State with Path Binding
impact: HIGH
impactDescription: enables deep linking, state restoration, and programmatic navigation
tags: nav, navigation-path, deep-linking, state, programmatic
---

## Manage Navigation State with Path Binding

An uncontrolled NavigationStack provides no way to programmatically push, pop, or restore the navigation state. Binding a NavigationPath to the stack lets you drive navigation from code, support deep links, and save or restore the full stack across app launches.

**Incorrect (uncontrolled NavigationStack with no path binding):**

```swift
struct OrderListView: View {
    let orders: [Order]

    var body: some View {
        NavigationStack { // no path binding, cannot push or pop programmatically
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
}
```

**Correct (NavigationStack with path binding for programmatic navigation):**

```swift
struct OrderListView: View {
    let orders: [Order]
    @State private var path = NavigationPath() // controls the navigation stack

    var body: some View {
        NavigationStack(path: $path) {
            List(orders) { order in
                NavigationLink(value: order) {
                    OrderRow(order: order)
                }
            }
            .navigationTitle("Orders")
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(order: order)
            }
            .toolbar {
                Button("Latest") {
                    if let latest = orders.first {
                        path.append(latest) // programmatic push
                    }
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
