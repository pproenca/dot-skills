---
title: Replace Combine Publishers with async/await
impact: MEDIUM-HIGH
impactDescription: eliminates AnyCancellable bags and retain-cycle risk
tags: conc, combine, async-await, structured-concurrency, migration
---

## Replace Combine Publishers with async/await

Combine publisher chains require manual lifecycle management through `Set<AnyCancellable>`. Forgetting to store a subscription causes it to be immediately cancelled, while retaining `self` in `.sink` closures creates retain cycles. Structured concurrency with `async/await` scopes the work automatically to the enclosing task -- when the task is cancelled, the work stops without any manual cleanup.

**Incorrect (manual cancellable management with retain-cycle risk):**

```swift
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [SearchResult] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task { await self.performSearch(query) }
            }
            .store(in: &cancellables)
    }

    private func performSearch(_ query: String) async {
        results = await SearchService.search(query: query)
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        List(viewModel.results) { result in
            SearchRow(result: result)
        }
        .searchable(text: $viewModel.searchText)
    }
}
```

**Correct (automatic scoping via structured concurrency):**

```swift
@Observable
@MainActor
class SearchViewModel {
    var searchText = ""
    var results: [SearchResult] = []

    func performSearch(_ query: String) async {
        results = await SearchService.search(query: query)
    }
}

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        List(viewModel.results) { result in
            SearchRow(result: result)
        }
        .searchable(text: $viewModel.searchText)
        .task(id: viewModel.searchText) {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await viewModel.performSearch(viewModel.searchText)
        }
    }
}
```

Reference: [AsyncSequence](https://developer.apple.com/documentation/swift/asyncsequence)
