---
title: Use .task(id:) for Reactive Data Loading
impact: HIGH
impactDescription: automatic cancellation eliminates stale-response bugs and resource leaks from concurrent inflight requests
tags: conc, task, reactive, cancellation, data-loading
---

## Use .task(id:) for Reactive Data Loading

Using `.onChange` with a manually created `Task` requires the developer to track and cancel the previous task before starting a new one. If cancellation is forgotten, multiple tasks run concurrently for stale values, wasting resources and risking out-of-order results. The `.task(id:)` modifier handles this automatically -- SwiftUI cancels the running task and launches a fresh one whenever the observed value changes.

**Incorrect (manual task lifecycle with no automatic cancellation):**

```swift
struct CategoryItemsView: View {
    @State var viewModel: CategoryItemsViewModel
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        VStack {
            CategoryPicker(selection: $viewModel.selectedCategory)
            ItemsList(items: viewModel.items)
        }
        .onChange(of: viewModel.selectedCategory) { _, newCategory in
            // Must remember to cancel the previous task
            loadTask?.cancel()
            loadTask = Task {
                await viewModel.loadItems(for: newCategory)
            }
        }
    }
}
```

**Correct (automatic cancellation and re-trigger on value change):**

```swift
struct CategoryItemsView: View {
    @State var viewModel: CategoryItemsViewModel

    var body: some View {
        VStack {
            CategoryPicker(selection: $viewModel.selectedCategory)
            ItemsList(items: viewModel.items)
        }
        .task(id: viewModel.selectedCategory) {
            // Automatically cancelled and re-launched
            // when selectedCategory changes
            await viewModel.loadItems(for: viewModel.selectedCategory)
        }
    }
}

@Observable
@MainActor
class CategoryItemsViewModel {
    var selectedCategory: Category = .all
    var items: [Item] = []
    private let fetchItemsUseCase: any FetchItemsUseCase

    init(fetchItemsUseCase: any FetchItemsUseCase) {
        self.fetchItemsUseCase = fetchItemsUseCase
    }

    func loadItems(for category: Category) async {
        items = (try? await fetchItemsUseCase.execute(category: category)) ?? []
    }
}
```

Reference: [task(id:priority:_:)](https://developer.apple.com/documentation/swiftui/view/task(id:priority:_:))
