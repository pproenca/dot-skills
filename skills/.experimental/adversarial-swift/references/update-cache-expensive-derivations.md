---
title: Cache expensive derivations instead of recomputing them in body
tags: update, body-execution, caching, sorting
---

## Cache expensive derivations instead of recomputing them in body

The wrong default is running an O(n) transform — `sorted()`, `filter`, grouping — in `body` or in a computed property `body` reads, inside a view that also carries unrelated frequently-changing state. Because the property is accessed during every body evaluation, the entire collection is re-processed for every unrelated tap or keystroke, even though the transform's inputs did not change. Caching the result in `@State` or an observable model, recomputed only when its actual inputs change, keeps body a lightweight description of the UI.

**Evidence of violation:** a computed property or inline `body` expression applying an O(n) transform (`sorted`, `filter`, `map`-chains, `Dictionary(grouping:)`) over a state or model collection, in a view that has at least one other mutation source (a `TextField` binding, counter, toggle) unrelated to the transform's inputs. PASS: the result is cached in `@State` or an `@Observable` model and recomputed via `.task(id:)` or `onChange` keyed on the transform's actual inputs. N/A: the view's only changing dependency is the transform's input, or the collection is static for the view's lifetime.

**Incorrect (every sighting tap re-sorts the whole collection):**

```swift
import SwiftUI

struct BirdRegistryView: View {
    @State private var birdNames: [String] = []
    @State private var sightingCount = 0

    private var sortedBirds: [String] {
        birdNames.sorted()
    }

    var body: some View {
        List(sortedBirds, id: \.self) { name in
            Button(name) { sightingCount += 1 }
        }
    }
}
```

**Correct (sort runs only when the names actually change):**

```swift
import SwiftUI

@Observable
final class BirdRegistryModel {
    var birdNames: [String] = []
    var sortedBirds: [String] = []

    func loadBirds() async {
        // ... fetch names, then cache the derived order once ...
        sortedBirds = birdNames.sorted()
    }
}

struct BirdRegistryView: View {
    @State private var model = BirdRegistryModel()
    @State private var sightingCount = 0

    var body: some View {
        List(model.sortedBirds, id: \.self) { name in
            Button(name) { sightingCount += 1 }
        }
        .task {
            await model.loadBirds()
        }
    }
}
```

Reference: expert SwiftUI reference (2026), “Streamlining view body execution”.
