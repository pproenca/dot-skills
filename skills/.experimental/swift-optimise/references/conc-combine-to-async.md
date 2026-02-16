---
title: Replace Combine Publishers with async/await
impact: CRITICAL
impactDescription: eliminates AnyCancellable bags and retain-cycle risk, reduces concurrency code by 40-60%
tags: conc, combine, async-await, structured-concurrency, migration
---

## Replace Combine Publishers with async/await

Combine publisher chains require manual lifecycle management through `Set<AnyCancellable>`. Forgetting to store a subscription causes it to be immediately cancelled, while retaining `self` in `.sink` closures creates retain cycles. Structured concurrency with `async/await` scopes the work automatically to the enclosing task -- when the task is cancelled, the work stops without any manual cleanup.

**Incorrect (manual cancellable management with retain-cycle risk):**

```swift
@Observable
@MainActor
class SearchViewModel {
    var searchText = ""
    var results: [SearchResult] = []
    private var cancellables = Set<AnyCancellable>()
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let searchService: any SearchServiceProtocol

    init(searchService: any SearchServiceProtocol) {
        self.searchService = searchService
        searchTextSubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task { await self.performSearch(query) }
            }
            .store(in: &cancellables)
    }

    func updateSearch(_ text: String) {
        searchText = text
        searchTextSubject.send(text)
    }

    private func performSearch(_ query: String) async {
        results = await searchService.search(query: query)
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
    private let searchService: any SearchServiceProtocol

    init(searchService: any SearchServiceProtocol) {
        self.searchService = searchService
    }

    func performSearch(_ query: String) async {
        results = (try? await searchService.search(query: query)) ?? []
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
            // Acts as a debounce: cancelled and restarted on each keystroke.
            // The 300ms sleep only completes after 300ms of inactivity.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await viewModel.performSearch(viewModel.searchText)
        }
    }
}
```

**Note on debounce behavior:** The `.task(id:)` + `Task.sleep` pattern behaves like Combine's `.debounce` -- it waits for a pause in changes before executing. Each keystroke cancels the previous sleep and starts a new one, so the search only fires after 300ms of inactivity.

**See also:** [`data-combine-avoid`](../../swift-ui-architect/references/data-combine-avoid.md) in swift-ui-architect for the architectural decision rule on when Combine is still appropriate.

Reference: [AsyncSequence](https://developer.apple.com/documentation/swift/asyncsequence)
