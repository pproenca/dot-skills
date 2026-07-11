---
title: Do not pass large shared structs into every list row
tags: update, list-performance, value-comparison, observable
---

## Do not pass large shared structs into every list row

The wrong default is passing one big shared struct — nested arrays, dictionaries of models — as a stored property into every row view of a `ForEach`. Any struct stored by a view becomes part of that view's value and therefore part of SwiftUI's update comparison, so when the parent updates for an unrelated reason, the framework must compare the large struct once per row to decide whether each row's body needs to run. In a list with hundreds of items, the cumulative cost of comparing nested collections slows the whole update cycle. Moving the shared data into an `@Observable` class reduces the comparison to a pointer check while keeping property-level update tracking.

**Evidence of violation:** a `ForEach`/`List` row view declaring a stored property whose type is a struct containing collection-typed properties (arrays or dictionaries of models), with the same instance passed to every row. PASS: rows receive only their element plus primitives/IDs, or the shared data is held in an `@Observable` class (reference comparison). N/A: the struct holds only scalar or `String` fields — the comparison is then cheap.

**Incorrect (the nested collections are compared once per row on every parent update):**

```swift
import SwiftUI

struct ConservationData {
    var statusDefinitions: [String: String]
    var regionalAlerts: [UUID: [String]]
}

struct AnimalRow: View {
    let animalName: String
    let conservationData: ConservationData

    var body: some View {
        Text(animalName)
    }
}
```

**Correct (rows store a reference — comparison is a pointer check):**

```swift
import SwiftUI

@Observable
final class ConservationDataProvider {
    var statusDefinitions: [String: String] = [:]
    var regionalAlerts: [UUID: [String]] = [:]
}

struct AnimalRow: View {
    let animalName: String
    let conservationData: ConservationDataProvider

    var body: some View {
        Text(animalName)
    }
}
```

Reference: expert SwiftUI reference (2026), “Choosing between value and reference types”.
