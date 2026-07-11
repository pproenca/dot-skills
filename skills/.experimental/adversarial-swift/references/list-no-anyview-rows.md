---
title: Never wrap ForEach row content in AnyView
tags: list, anyview, type-erasure, lazy-loading
---

## Never wrap ForEach row content in AnyView

The wrong default is returning `AnyView(...)` from a `ForEach` row closure — usually to silence an opaque-type error. Type erasure "hides the type of the content from SwiftUI. Since the underlying structure is hidden, SwiftUI cannot determine the number of rows without evaluating the ForEach closure for every element in the collection upfront. This eliminates the performance benefits of lazy loading." Extracting the row into a dedicated view struct gives each element a constant, statically known view count with no erasure.

**Evidence of violation:** `AnyView(` appears inside a `ForEach` closure of a `List` or lazy container (`LazyVStack`, `LazyHStack`, lazy grids). PASS: row content is a concrete view — the book's prescription is that "the row is extracted into a dedicated, single view." N/A: no `ForEach` in the target.

**Incorrect (type erasure forces upfront evaluation of every row):**

```swift
struct Walk: Identifiable { let id = UUID() }
struct WalkRow: View { let walk: Walk; var body: some View { Text(walk.id.uuidString) } }

struct DayWalksView: View {
    let walks: [Walk]

    var body: some View {
        List {
            ForEach(walks) { walk in
                AnyView(
                    WalkRow(walk: walk)
                )
            }
        }
    }
}
```

**Correct (a dedicated row view keeps loading lazy):**

```swift
struct Walk: Identifiable { let id = UUID() }
struct WalkRow: View { let walk: Walk; var body: some View { Text(walk.id.uuidString) } }

struct DayWalksView: View {
    let walks: [Walk]

    var body: some View {
        List {
            ForEach(walks) { walk in
                WalkRow(walk: walk)
            }
        }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Maximizing the performance of dynamic lists”
