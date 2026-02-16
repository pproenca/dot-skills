---
title: "Combine Sink Retains Self Without Cancellable Storage"
impact: MEDIUM-HIGH
impactDescription: "subscription outlives view, captures stale self reference"
tags: mem, combine, sink, cancellable, anycancellable
---

## Combine Sink Retains Self Without Cancellable Storage

Calling `.sink { self.update($0) }` on a publisher captures `self` strongly. If the returned `AnyCancellable` is not stored, the subscription is immediately cancelled and the result is silently lost. If the cancellable is stored but `self` is captured strongly, the subscription keeps the ViewModel alive after the screen is dismissed, processing stale data.

**Incorrect (strong self in sink, ViewModel outlives its screen):**

```swift
import Combine
import Observation

@Observable
final class SearchViewModel {
    var results: [String] = []
    var query: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let searchService: SearchService

    init(searchService: SearchService) {
        self.searchService = searchService
        setupSearch()
    }

    private func setupSearch() {
        searchService.resultsPublisher
            .receive(on: DispatchQueue.main)
            .sink { results in
                self.results = results // strong capture — ViewModel never deallocates
            }
            .store(in: &cancellables)
    }

    deinit { print("SearchViewModel deallocated") }
}
```

**Proof Test (exposes the leak — ViewModel survives after reference dropped):**

```swift
import XCTest
import Combine
@testable import MyApp

final class CombineSinkRetainTests: XCTestCase {

    func testViewModelDeallocatesWhenScreenDismissed() {
        weak var weakVM: SearchViewModel?
        let service = SearchService()

        autoreleasepool {
            let vm = SearchViewModel(searchService: service)
            weakVM = vm
        }

        // Publisher still holds strong reference to ViewModel via sink closure
        XCTAssertNil(weakVM, "SearchViewModel leaked — sink closure retained self")
    }
}
```

**Correct (weak self in sink, cancellables auto-cancel on deallocation):**

```swift
import Combine
import Observation

@Observable
final class SearchViewModel {
    var results: [String] = []
    var query: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let searchService: SearchService

    init(searchService: SearchService) {
        self.searchService = searchService
        setupSearch()
    }

    private func setupSearch() {
        searchService.resultsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in // weak self — subscription dies with ViewModel
                self?.results = results
            }
            .store(in: &cancellables)
    }

    deinit { print("SearchViewModel deallocated") }
}
```
