---
title: Filter collections before ForEach so each element resolves to a constant view count
tags: list, foreach, lazy-loading, filtering
---

## Filter collections before ForEach so each element resolves to a constant view count

The wrong default is filtering inside the `ForEach` closure — an `if` that optionally shows a row. Lists gather all element identifiers eagerly but create row content lazily, and that laziness depends on each element resolving to a constant number of views. When an `if` makes the count zero-or-one, "SwiftUI will evaluate the ForEach closure for every single element in the collection upfront," saturating the main thread and inflating the memory footprint before a single row is displayed. Filtering the collection before the `ForEach` — cached in a model or state, not recomputed per body — keeps the per-element view count constant, which is what allows lazy row creation.

**Evidence of violation:** an `if` statement without a view-producing `else`, conditioning on element properties, directly inside a `ForEach` closure within a `List` or lazy container (`LazyVStack`, `LazyHStack`, lazy grids). PASS: the collection is filtered before reaching the `ForEach` (cached in a view model or state, as in the source's day-walks example) and each element resolves to a fixed number of views. An `if/else` yielding exactly one view per branch does NOT fire this rule — the count is a constant 1. N/A: no `ForEach` in the target, or the container is non-lazy (`VStack`, `HStack`) — the reviewer must cite the container type to claim this.

**Incorrect (every element is instantiated upfront to discover the row count):**

```swift
import SwiftUI

struct Walk: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var durationInDays: Int
}

struct DayWalksView: View {
    @State private var allWalks: [Walk] = []

    var body: some View {
        List {
            ForEach(allWalks) { walk in
                // ⚠️ Evaluates for every element upfront
                if walk.durationInDays == 1 {
                    VStack(alignment: .leading) {
                        // ... walk row ...
                    }
                }
            }
        }
        .task {
            allWalks = await loadAllWalks()
        }
    }

    private func loadAllWalks() async -> [Walk] {
        // ... load all walks ...
        []
    }
}
```

**Correct (pre-filtered collection keeps the view count constant and rows lazy):**

```swift
import SwiftUI

struct Walk: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var durationInDays: Int
}

@Observable class DayWalksViewModel {
    var walks: [Walk] = []

    func loadWalks() async {
        let allWalks = await loadAllWalks()
        walks = allWalks.filter { $0.durationInDays == 1 }
    }

    private func loadAllWalks() async -> [Walk] {
        // ... load all walks ...
        []
    }
}

struct DayWalksView: View {
    @State private var viewModel = DayWalksViewModel()

    var body: some View {
        List {
            ForEach(viewModel.walks) { walk in
                WalkRow(walk: walk)
            }
        }
        .task {
            await viewModel.loadWalks()
        }
    }
}

struct WalkRow: View {
    let walk: Walk

    var body: some View {
        VStack(alignment: .leading) {
            // ... row subviews ...
        }
    }
}
```
