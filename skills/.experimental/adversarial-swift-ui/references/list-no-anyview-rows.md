---
title: Never wrap ForEach row content in AnyView
tags: list, anyview, type-erasure, lazy-loading
---

## Never wrap ForEach row content in AnyView

The wrong default is returning `AnyView(...)` from a `ForEach` row closure — usually to silence an opaque-type error. Type erasure hides the row structure from SwiftUI: "Since the underlying structure is hidden, SwiftUI cannot determine the number of rows without evaluating the ForEach closure for every element in the collection upfront. This eliminates the performance benefits of lazy loading" — significant overhead and a growing memory footprint as the list scales. Extracting the row into a dedicated view struct gives each element a constant, statically known view count with no erasure.

**Evidence of violation:** `AnyView(` appears inside a `ForEach` closure of a `List` or lazy container (`LazyVStack`, `LazyHStack`, lazy grids). PASS: row content is a concrete view — the source's prescription is a dedicated, single row view struct per element. N/A: no `ForEach` in the target.

**Incorrect (type erasure forces upfront evaluation of every row):**

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
                // ⚠️ Evaluates for every element upfront
                AnyView(
                    Text(walk.name) // ... row content ...
                )
            }
        }
        .task {
            await viewModel.loadWalks()
        }
    }
}
```

**Correct (a dedicated row view keeps loading lazy):**

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
