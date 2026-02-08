---
title: Use .task(id:) for Reactive Data Loading
impact: MEDIUM-HIGH
impactDescription: automatic cancellation and re-trigger on value change
tags: conc, task, reactive, cancellation, data-loading
---

## Use .task(id:) for Reactive Data Loading

Using `.onChange` with a manually created `Task` requires the developer to track and cancel the previous task before starting a new one. If cancellation is forgotten, multiple tasks run concurrently for stale values, wasting resources and risking out-of-order results. The `.task(id:)` modifier handles this automatically -- SwiftUI cancels the running task and launches a fresh one whenever the observed value changes.

**Incorrect (manual task lifecycle with no automatic cancellation):**

```swift
struct CategoryItemsView: View {
    @State private var selectedCategory: Category = .all
    @State private var items: [Item] = []
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        VStack {
            CategoryPicker(selection: $selectedCategory)
            ItemsList(items: items)
        }
        .onChange(of: selectedCategory) { _, newCategory in
            // Must remember to cancel the previous task
            loadTask?.cancel()
            loadTask = Task {
                items = await ItemService.fetchItems(
                    for: newCategory
                )
            }
        }
    }
}
```

**Correct (automatic cancellation and re-trigger on value change):**

```swift
struct CategoryItemsView: View {
    @State private var selectedCategory: Category = .all
    @State private var items: [Item] = []

    var body: some View {
        VStack {
            CategoryPicker(selection: $selectedCategory)
            ItemsList(items: items)
        }
        .task(id: selectedCategory) {
            // Automatically cancelled and re-launched
            // when selectedCategory changes
            items = await ItemService.fetchItems(
                for: selectedCategory
            )
        }
    }
}
```

Reference: [task(id:priority:_:)](https://developer.apple.com/documentation/swiftui/view/task(id:priority:_:))
