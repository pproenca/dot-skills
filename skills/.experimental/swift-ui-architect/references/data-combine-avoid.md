---
title: Prefer async/await Over Combine for New Code
impact: LOW-MEDIUM
impactDescription: 50-70% less code for fetch-and-display operations vs Combine pipelines
tags: data, combine, async-await, concurrency, modern
---

## Prefer async/await Over Combine for New Code

With iOS 17+ and Swift 5.9+, `async`/`await` with structured concurrency replaces most Combine use cases. `async`/`await` provides linear code flow (easier to read and debug), built-in cancellation via `Task` and `.task {}`, and proper error propagation with `try`/`catch`. Reserve Combine only for reactive streams where you need operators like `debounce`, `throttle`, or `combineLatest`.

**Incorrect (Combine for simple fetch-and-display — unnecessary complexity):**

```swift
import Combine

class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [SearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let searchService: SearchService

    init(searchService: SearchService) {
        self.searchService = searchService

        // 15+ lines of Combine pipeline for a simple search
        $query
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                self.isLoading = true
                return searchService.search(query: query)
                    .catch { error -> Just<[SearchResult]> in
                        self.errorMessage = error.localizedDescription
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    // Hard to debug: breakpoints in closures, weak self everywhere,
    // error handling interleaved with data flow, type erasure obscures types
}
```

**Correct (async/await — linear, readable, debuggable):**

```swift
@Observable
class SearchViewModel {
    var query = ""
    var results: [SearchResult] = []
    var isLoading = false
    var errorMessage: String?

    private let searchService: any SearchServiceProtocol

    init(searchService: any SearchServiceProtocol) {
        self.searchService = searchService
    }

    // Clear, linear code — reads top-to-bottom like synchronous code
    func search() async {
        let currentQuery = query
        guard !currentQuery.isEmpty else {
            results = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Cancellation is automatic via structured concurrency
            let searchResults = try await searchService.search(query: currentQuery)

            // Check if query changed while we were fetching
            guard query == currentQuery else { return }

            results = searchResults
            errorMessage = nil
        } catch is CancellationError {
            // Task was cancelled (e.g., view disappeared) — do nothing
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        List(viewModel.results) { result in
            SearchResultRow(result: result)
        }
        .searchable(text: $viewModel.query)
        .task(id: viewModel.query) {
            // Built-in debounce alternative: wait before searching
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await viewModel.search()
        }
        // .task(id:) cancels the previous task when query changes
        // — acts as removeDuplicates + debounce + flatMapLatest combined
    }
}
```

**When Combine IS still appropriate:**

```swift
// Real-time streams where Combine operators add genuine value
import Combine

class BluetoothSensorViewModel {
    private var cancellables = Set<AnyCancellable>()

    init(sensor: BluetoothSensor) {
        // combineLatest, throttle, scan — genuine reactive stream processing
        sensor.heartRatePublisher
            .combineLatest(sensor.cadencePublisher)
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .scan(WorkoutStats()) { stats, values in
                stats.updated(heartRate: values.0, cadence: values.1)
            }
            .sink { [weak self] stats in
                self?.currentStats = stats
            }
            .store(in: &cancellables)
    }
}
// WebSocket, Bluetooth, sensor data, multi-source merging — Combine shines here
```

**Decision rule:** If your code does fetch → transform → display, use `async`/`await`. If your code merges multiple continuous streams with time-based operators, use Combine.

Reference: [Apple Documentation — Concurrency](https://developer.apple.com/documentation/swift/concurrency)
