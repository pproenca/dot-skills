---
title: Use Sheets for Modal Presentation
impact: HIGH
impactDescription: sheets provide standard iOS modal pattern with automatic dismiss gesture
tags: nav, sheets, modal, presentation, forms
---

## Use Sheets for Modal Presentation

Pushing a creation form onto the navigation stack mixes hierarchical drill-down with modal intent, confusing the user about where they are in the app. Sheets signal a self-contained task that can be dismissed with a swipe, and they preserve the navigation stack underneath.

**Incorrect (pushing a creation form onto the navigation stack):**

```swift
struct GroceryListView: View {
    @State private var items: [GroceryItem] = []

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name)
            }
            .navigationTitle("Groceries")
            .toolbar {
                NavigationLink("Add") { // pushes form onto stack as if drilling down
                    AddGroceryItemView(items: $items)
                }
            }
        }
    }
}
```

**Correct (presenting a creation form as a sheet):**

```swift
struct GroceryListView: View {
    @State private var items: [GroceryItem] = []
    @State private var isAddingItem = false

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name)
            }
            .navigationTitle("Groceries")
            .toolbar {
                Button("Add") { isAddingItem = true }
            }
            .sheet(isPresented: $isAddingItem) { // modal presentation for a self-contained task
                AddGroceryItemView(items: $items)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
