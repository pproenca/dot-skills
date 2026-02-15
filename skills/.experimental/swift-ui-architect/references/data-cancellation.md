---
title: Use .task Automatic Cancellation — Never Manage Task Lifecycle Manually
impact: MEDIUM
impactDescription: prevents 100% of Task lifecycle leaks with zero manual management code
tags: data, cancellation, task, lifecycle, structured-concurrency
---

## Use .task Automatic Cancellation — Never Manage Task Lifecycle Manually

`.task {}` provides structured concurrency tied to the view lifecycle — it cancels automatically when the view disappears. Manual `Task` creation (`Task { }`, `Task.detached { }`) requires manual cancellation and risks completing after the view is gone, updating deallocated state. Use `.task` for all view-triggered async work. The `.task(id:)` variant automatically restarts when the id value changes.

**Incorrect (manual Task lifecycle management — error-prone, resource leaks):**

```swift
struct SearchResultsView: View {
    @State var viewModel: SearchResultsViewModel
    @State private var searchTask: Task<Void, Never>?
    //                 ^^^^^^^^^ manual Task storage

    var body: some View {
        List(viewModel.results) { result in
            ResultRow(result: result)
        }
        .searchable(text: $viewModel.query)
        .onChange(of: viewModel.query) { _, newQuery in
            // Manual cancel + recreate on every keystroke
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await viewModel.search(query: newQuery)
            }
        }
        .onDisappear {
            // Easy to forget — if omitted, Task runs after view is gone
            searchTask?.cancel()
            searchTask = nil
        }
    }
}

// Problems:
// 1. Forgetting .onDisappear cancel → leaked Task, use-after-disappear
// 2. Race condition: onChange fires before onDisappear processes cancel
// 3. @State var searchTask adds view state that has nothing to do with UI
// 4. Every caller must remember the cancel/recreate dance
```

**Correct (.task with automatic cancellation — zero manual management):**

```swift
struct SearchResultsView: View {
    @State var viewModel: SearchResultsViewModel

    var body: some View {
        List(viewModel.results) { result in
            ResultRow(result: result)
        }
        .searchable(text: $viewModel.query)
        .task(id: viewModel.query) {
            // .task(id:) handles everything:
            // 1. Cancels the previous task when query changes
            // 2. Waits for debounce period
            // 3. Starts new search
            // 4. Auto-cancels when view disappears
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await viewModel.search(query: viewModel.query)
        }
        // No @State var task, no .onDisappear, no manual cancel
    }
}
```

**Correct (.task(id:) for dependent data reloading):**

```swift
struct ProductListView: View {
    @State var viewModel: ProductListViewModel
    @State private var selectedCategory: Category = .all
    @State private var sortOrder: SortOrder = .newest

    var body: some View {
        VStack {
            CategoryPicker(selection: $selectedCategory)
            SortPicker(selection: $sortOrder)

            ProductGrid(products: viewModel.products)
                // Combine multiple dependencies into a single hashable value
                .task(id: FilterKey(category: selectedCategory, sort: sortOrder)) {
                    await viewModel.loadProducts(
                        category: selectedCategory,
                        sort: sortOrder
                    )
                }
        }
    }
}

// Hashable struct to combine multiple task dependencies
private struct FilterKey: Hashable {
    let category: Category
    let sort: SortOrder
}

// Lifecycle:
// 1. View appears → .task starts → loadProducts runs
// 2. User changes category → id changes → previous task cancelled → new task starts
// 3. User changes sort → id changes → previous task cancelled → new task starts
// 4. User navigates away → view disappears → current task cancelled automatically
```

**Key guarantees of .task:**
- Starts when view appears (or when `id` changes)
- Cancels when view disappears (or when `id` changes before restart)
- Cooperative cancellation: `await` checkpoints respond to `Task.isCancelled`
- No stored `Task` references, no `.onDisappear` cleanup, no race conditions

Reference: [Apple Documentation — View fundamentals](https://developer.apple.com/documentation/swiftui/view-fundamentals)
