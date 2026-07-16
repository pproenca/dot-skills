---
title: Compare scalar identifiers in onChange and task id, not whole collections
tags: task, onchange, equality-cost, identifiers
---

## Compare scalar identifiers in onChange and task id, not whole collections

The wrong default is passing an entire collection or a multi-property model as the compared value of `.onChange(of:)` or `.task(id:)`. SwiftUI must evaluate these values during every update cycle to detect a change, so the framework performs an equality check over the entire collection each time the view updates — with large datasets or models with expensive equality, that overhead accumulates into dropped frames. The source's remedy is to observe simple, lightweight identifiers — a unique ID, a count, or a version property — rather than comparing the whole data set.

**Evidence of violation:** the `of:` argument of `.onChange` or the `id:` argument of `.task` is an `Array`, `Dictionary`, or `Set` of model values, or a struct with more than one stored property or any collection-typed stored property. PASS: a scalar — an ID, a `count`, a version or hash property, a `Bool`, an enum — or a struct with a single scalar stored property (the reviewer must cite the type declaration). N/A: no `.onChange`/`.task(id:)` in the target.

**Incorrect (full-array equality check on every update cycle):**

```swift
import SwiftUI

struct Route: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

struct RouteRow: View {
    let route: Route

    var body: some View {
        Text(route.name)
    }
}

struct RouteListView: View {
    let routes: [Route]

    @State private var statistics = ""

    var body: some View {
        List {
            Section {
                Text(statistics)
            }

            Section {
                ForEach(routes) { route in
                    RouteRow(route: route)
                }
            }
        }
        // ⚠️ Large collection comparison
        .onChange(of: routes, initial: true) { _, newRoutes in
            statistics = "Total routes: \(newRoutes.count)"
        }
    }
}
```

**Correct (cheap scalar comparison detects the same change):**

```swift
import SwiftUI

struct Route: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

struct RouteRow: View {
    let route: Route

    var body: some View {
        Text(route.name)
    }
}

struct RouteListView: View {
    let routes: [Route]

    @State private var statistics = ""

    var body: some View {
        List {
            Section {
                Text(statistics)
            }

            Section {
                ForEach(routes) { route in
                    RouteRow(route: route)
                }
            }
        }
        .onChange(of: routes.count, initial: true) { _, newCount in
            statistics = "Total routes: \(newCount)"
        }
    }
}
```
