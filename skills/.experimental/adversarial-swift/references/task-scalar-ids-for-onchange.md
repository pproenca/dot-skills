---
title: Compare scalar identifiers in onChange and task id, not whole collections
tags: task, onchange, equality-cost, identifiers
---

## Compare scalar identifiers in onChange and task id, not whole collections

The wrong default is passing an entire collection or a multi-property model as the compared value of `.onChange(of:)` or `.task(id:)`. SwiftUI must evaluate these values during every update cycle to detect a change, so "the framework will have to perform a comparison of the entire collection" each time — with large datasets or expensive equality checks this overhead leads to dropped frames. The book's remedy is to use "simple and lightweight identifiers like a unique ID or a version property" instead.

**Evidence of violation:** the `of:` argument of `.onChange` or the `id:` argument of `.task` is an `Array`, `Dictionary`, or `Set` of model values, or a struct with more than one stored property or any collection-typed stored property. PASS: a scalar — an ID, a `count`, a version or hash property, a `Bool`, an enum — or a struct with a single scalar stored property (the reviewer must cite the type declaration). N/A: no `.onChange`/`.task(id:)` in the target.

**Incorrect (full-array equality check on every update cycle):**

```swift
struct Route: Equatable { let name: String }

struct RouteListView: View {
    let routes: [Route]

    @State private var statistics = ""

    var body: some View {
        List {
            Text(statistics)
        }
        .onChange(of: routes, initial: true) { _, newRoutes in
            statistics = "Total routes: \(newRoutes.count)"
        }
    }
}
```

**Correct (cheap scalar comparison detects the same change):**

```swift
struct Route: Equatable { let name: String }

struct RouteListView: View {
    let routes: [Route]

    @State private var statistics = ""

    var body: some View {
        List {
            Text(statistics)
        }
        .onChange(of: routes.count, initial: true) { _, newCount in
            statistics = "Total routes: \(newCount)"
        }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Running tasks in response to state changes”
