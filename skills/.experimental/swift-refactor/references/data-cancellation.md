---
title: Use .task Automatic Cancellation — Never Manage Tasks Manually
impact: MEDIUM
impactDescription: prevents leaked tasks, race conditions, and state mutations after view disposal
tags: data, cancellation, task, structured-concurrency, lifecycle
---

## Use .task Automatic Cancellation — Never Manage Tasks Manually

Storing `Task` handles in properties and manually cancelling them in `onDisappear` is error-prone — it's easy to forget cancellation, create race conditions, or cancel too early. The `.task` modifier provides automatic structured cancellation: the task is cancelled when the view disappears, and restarted with `.task(id:)` when a dependency changes.

**Incorrect (manual Task management — leak-prone, race-prone):**

```swift
@Observable
class SearchViewModel {
    var query: String = ""
    var results: [SearchResult] = []
    private var searchTask: Task<Void, Never>?
    // Manual task tracking — easy to forget cancellation

    func search() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            results = (try? await searchUseCase.execute(query: query)) ?? []
        }
    }
}

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        List(viewModel.results) { result in
            Text(result.title)
        }
        .searchable(text: $viewModel.query)
        .onChange(of: viewModel.query) {
            viewModel.search()
        }
        .onDisappear {
            // Easy to forget this — leaked task continues
            viewModel.searchTask?.cancel()
        }
    }
}
```

**Correct (.task with id — automatic cancellation and restart):**

```swift
@Observable
class SearchViewModel {
    var query: String = ""
    var results: [SearchResult] = []

    private let searchUseCase: SearchUseCase

    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase
    }

    func search() async {
        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }
        results = (try? await searchUseCase.execute(query: query)) ?? []
    }
}

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        List(viewModel.results) { result in
            Text(result.title)
        }
        .searchable(text: $viewModel.query)
        .task(id: viewModel.query) {
            // Automatically cancelled when query changes or view disappears
            // No manual Task tracking needed
            await viewModel.search()
        }
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
