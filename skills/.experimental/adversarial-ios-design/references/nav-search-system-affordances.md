---
title: Surface search with the system affordances in a primary position
tags: nav, search, searchable, discoverability
---

## Surface search with the system affordances in a primary position

The wrong default is a hand-rolled `TextField` decorated with a magnifying glass, dropped mid-screen and wired to manual filtering. It forfeits everything `.searchable` provides — the toolbar-integrated field, suggestions, scopes, tokens, and the placement conventions users already know — and it multiplies: a second bespoke search box appears on another screen and the app now has two disconnected searches over the same content. Content search goes through `.searchable(text:)` on the navigation container or a dedicated `Tab(role: .search)`; the app keeps a single global entry point.

**Evidence of violation:** content search implemented as a plain `TextField` (with or without a `magnifyingglass` icon) driving manual filtering, with no `.searchable` and no `Tab(role: .search)` in the target; or more than one global search entry point over the same content. Carve-out: a view-scoped filter field that narrows only the visible control's options (not the app's content) — the reviewer must cite the scoping; absent that evidence, fail closed. PASS: `.searchable(text:)` on the navigation container, or a `Tab(role: .search)` — cite the affordance. N/A: the target has no search functionality.

**Incorrect (a bespoke search box with none of the system behavior):**

```swift
import SwiftUI

struct StationListView: View {
    @State private var query = ""
    let stations: [RadioStation]

    var body: some View {
        VStack {
            // ⚠️ Hand-rolled search field instead of .searchable
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search stations", text: $query)
            }
            .padding(10)
            .background(.quaternary, in: .rect(cornerRadius: 10))
            .padding(.horizontal)

            List(stations.filter { query.isEmpty || $0.name.localizedStandardContains(query) }) { station in
                StationRow(station: station)
            }
        }
        .navigationTitle("Stations")
    }
}
```

**Correct (the system search field, placed by the system):**

```swift
import SwiftUI

struct StationListView: View {
    @State private var query = ""
    let stations: [RadioStation]

    private var results: [RadioStation] {
        query.isEmpty ? stations : stations.filter { $0.name.localizedStandardContains(query) }
    }

    var body: some View {
        List(results) { station in
            StationRow(station: station)
        }
        .navigationTitle("Stations")
        .searchable(text: $query, prompt: "Search stations")
    }
}
```

Reference: [HIG — Searching](https://developer.apple.com/design/human-interface-guidelines/searching), [HIG — Search fields](https://developer.apple.com/design/human-interface-guidelines/search-fields)
