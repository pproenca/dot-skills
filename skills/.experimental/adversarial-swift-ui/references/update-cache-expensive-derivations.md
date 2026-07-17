---
title: Cache expensive derivations instead of recomputing them in body
tags: update, body-execution, caching, sorting
---

## Cache expensive derivations instead of recomputing them in body

The wrong default is running an O(n) transform — `sorted()`, `filter`, grouping — in `body` or in a computed property `body` reads, inside a view that also carries unrelated frequently-changing state. Because the property is accessed during every body evaluation, the entire collection is re-processed for every unrelated tap or keystroke, even though the transform's inputs did not change. As the collection grows, the cumulative cost of these redundant passes can exceed the main thread's refresh budget. Caching the result in an observable model or `@State`, recomputed only when its actual inputs change, keeps body a lightweight description of the UI.

**Evidence of violation:** all three legs must be cited — (1) a computed property or inline `body` expression applying an O(n) transform (`sorted`, `filter`, `map`-chains, `Dictionary(grouping:)`) over a state or model collection, read during body evaluation, (2) at least one other mutation source in the same view that changes at interaction frequency (a `TextField` binding, `Stepper`, counter button, or gesture-driven `@State`) unrelated to the transform's inputs, and (3) a materiality citation — the collection is unbounded at the call site (loaded from a network, database, or user library, growable without limit), named via its loading site. PASS: the result is cached in an `@Observable` model or `@State` and recomputed via `.task(id:)` or `onChange` keyed on the transform's actual inputs. N/A: the view's only changing dependency is the transform's input, the collection is static for the view's lifetime, or the collection is small and bounded by construction (one record's line items, a screen's fixed set of options) — a trivial transform recomputed redundantly is not a violation without the unbounded-input leg.

**Incorrect (every sighting tap re-sorts the whole bird collection):**

```swift
import SwiftUI

struct BirdRegistryView: View {
    var sortAlphabetically: Bool
        
    @State private var birdNames: [String] = []
    @State private var sightings: [String: Int] = [:]
    
    // ⚠️ Gets re-evaluated with unrelated state changes
    private var sortedBirds: [String] {
        birdNames.sorted()
    }
    
    var body: some View {
        List(
            sortAlphabetically ? sortedBirds : birdNames,
            id: \.self
        ) { name in
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                
                Text("""
                Spotted ^[\(
                    sightings[name, default: 0]
                ) times](inflect: true)
                """).font(.subheadline)
                
                RecordBirdSightingButton(
                    birdName: name,
                    sightings: $sightings
                )
            }
        }
        .task {
            if birdNames.isEmpty {
                // ... load all birds ...
            }
        }
    }
}

// Supporting view stubbed so the example compiles standalone.
struct RecordBirdSightingButton: View {
    let birdName: String
    @Binding var sightings: [String: Int]

    var body: some View {
        Button("Record sighting") {
            sightings[birdName, default: 0] += 1
        }
    }
}
```

**Correct (the sort runs only when the data loads or the preference changes):**

```swift
import SwiftUI

@Observable
class BirdRegistryViewModel {
    var birdNames: [String] = []
    var sortedBirds: [String] = []
    var sightings: [String: Int] = [:]
    
    func loadBirds() async {
        // ... load all birds ...
    }
    
    func sortBirds() {
        sortedBirds = birdNames.sorted()
    }
}

struct BirdRegistryView: View {
    var sortAlphabetically: Bool
    
    @State private var viewModel = BirdRegistryViewModel()
    
    var body: some View {
        List(
            sortAlphabetically ? viewModel.sortedBirds : viewModel.birdNames,
            id: \.self
        ) { name in
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                
                Text("""
                Spotted ^[\(
                    viewModel.sightings[name, default: 0]
                ) times](inflect: true)
                """).font(.subheadline)
                
                RecordBirdSightingButton(
                    birdName: name,
                    sightings: $viewModel.sightings
                )
            }
        }
        .task {
            if viewModel.birdNames.isEmpty {
                await viewModel.loadBirds()
                
                if sortAlphabetically {
                    viewModel.sortBirds()
                }
            }
        }
        .task(id: sortAlphabetically) {
            if sortAlphabetically && viewModel.sortedBirds.isEmpty {
                viewModel.sortBirds()
            }
        }
    }
}

// Supporting view stubbed so the example compiles standalone.
struct RecordBirdSightingButton: View {
    let birdName: String
    @Binding var sightings: [String: Int]

    var body: some View {
        Button("Record sighting") {
            sightings[birdName, default: 0] += 1
        }
    }
}
```
