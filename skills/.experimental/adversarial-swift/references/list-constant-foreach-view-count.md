---
title: Filter collections before ForEach so each element resolves to a constant view count
tags: list, foreach, lazy-loading, filtering
---

## Filter collections before ForEach so each element resolves to a constant view count

The wrong default is filtering inside the `ForEach` closure — an `if` that optionally shows a row. When SwiftUI cannot determine how many views an element resolves to, "SwiftUI will evaluate the ForEach closure for every single element in the collection upfront," saturating the main thread and inflating the memory footprint before a single row is displayed. Pre-filtering the collection keeps each element at a constant view count, which is what allows lazy row creation.

**Evidence of violation:** an `if` on element data (without a view-producing `else`) directly inside a `ForEach` closure within a `List` or lazy container (`LazyVStack`, `LazyHStack`, lazy grids), making the per-element view count zero-or-one. PASS: the collection is filtered before the `ForEach` — cached in state or a model, as in the source's view-model example — and each element resolves to a fixed number of views. N/A: the `if/else` yields exactly one view per branch (constant count), or the container is non-lazy and trivially small — the reviewer must cite the container type to claim this.

**Incorrect (every element is instantiated upfront to discover the row count):**

```swift
struct Walk: Identifiable { let id = UUID(); let durationInDays: Int }
struct WalkRow: View { let walk: Walk; var body: some View { Text(walk.id.uuidString) } }

struct DayWalksView: View {
    let allWalks: [Walk]

    var body: some View {
        List {
            ForEach(allWalks) { walk in
                if walk.durationInDays == 1 {
                    WalkRow(walk: walk)
                }
            }
        }
    }
}
```

**Correct (pre-filtered collection keeps the view count constant and rows lazy):**

```swift
struct Walk: Identifiable { let id = UUID(); let durationInDays: Int }
struct WalkRow: View { let walk: Walk; var body: some View { Text(walk.id.uuidString) } }
@Observable @MainActor final class DayWalksViewModel { var dayWalks: [Walk] = []; func loadDayWalks() async {} }

struct DayWalksView: View {
    @State private var viewModel = DayWalksViewModel()

    var body: some View {
        List {
            ForEach(viewModel.dayWalks) { walk in
                WalkRow(walk: walk)
            }
        }
        .task {
            await viewModel.loadDayWalks()
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Maximizing the performance of dynamic lists”
