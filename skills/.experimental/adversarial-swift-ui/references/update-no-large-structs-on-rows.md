---
title: Do not pass large shared structs into every list row
tags: update, list-performance, value-comparison, observable
---

## Do not pass large shared structs into every list row

The wrong default is passing one big shared struct — nested arrays, dictionaries of models — as a stored property into every row view of a `ForEach`. Any struct stored by a view becomes part of that view's value and therefore part of SwiftUI's update comparison, so when the parent updates for an unrelated reason, the framework must compare the large struct once per row to decide whether each row's body needs to run — even though the shared data has not changed at all. In a list with hundreds of items, the cumulative cost of comparing nested collections slows the whole update cycle. Moving the shared data into an `@Observable` class reduces the comparison to a pointer check while keeping property-level update tracking.

**Evidence of violation:** a view used as `ForEach`/`List` row content declaring a stored property whose type is a struct containing collection-typed fields (arrays or dictionaries), where that property is not the `ForEach` element itself and the call site passes the same instance to every row. PASS: rows receive only their element plus primitives, IDs, or bindings, or the shared data is held in an `@Observable` class (reference comparison). N/A: the shared struct holds only scalar or `String` fields — the comparison is then cheap.

**Incorrect (the nested collections are compared once per row on every parent update):**

```swift
import SwiftUI

struct ConservationData {
    var statusDefinitions: [StatusDefinition]
    var regionalAlerts: [Region: [Alert]]
    var lastUpdated: Date
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]
    let settings: AnimalListSettingsProvider
    let conservationData: ConservationData
    
    var body: some View {
        List {
            ForEach(animalClasses) { animalClass in
                Section(animalClass.name) {
                    ForEach(
                        settings.sortByConservationStatus
                        ? animalClass.animals.sorted(using: KeyPathComparator(\.conservationStatus))
                        : animalClass.animals
                    ) { animal in
                        AnimalRow(
                            animal: animal,
                            settings: settings,
                            conservationData: conservationData
                        )
                    }
                }
            }
        }
    }
}

struct AnimalRow: View {
    let animal: Animal
    let settings: AnimalListSettingsProvider
    
    // ⚠️ Can make view value comparison expensive
    let conservationData: ConservationData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(animal.name)
            
            HStack {
                if settings.showScientificNames {
                    Text(animal.scientificName)
                }
                ConservationStatusBadge(status: animal.conservationStatus)
            }
        }
    }
}
// Supporting types stubbed so the example compiles standalone.
@Observable class AnimalListSettingsProvider {
    var sortByConservationStatus = false
    var showScientificNames = true
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

struct Animal: Identifiable {
    var id = UUID()
    var name: String
    var scientificName: String
    var conservationStatus: String
}

struct StatusDefinition {
    var status: String
    var text: String
}

struct Region: Hashable {
    var name: String
}

struct Alert {
    var message: String
}

struct ConservationStatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
    }
}
```

**Correct (rows store a reference — comparison is a pointer check):**

```swift
import SwiftUI

@Observable class ConservationData {
    var statusDefinitions: [StatusDefinition] = []
    var regionalAlerts: [Region: [Alert]] = [:]
    var lastUpdated = Date()
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]
    let settings: AnimalListSettingsProvider
    let conservationData: ConservationData
    
    var body: some View {
        List {
            ForEach(animalClasses) { animalClass in
                Section(animalClass.name) {
                    ForEach(
                        settings.sortByConservationStatus
                        ? animalClass.animals.sorted(using: KeyPathComparator(\.conservationStatus))
                        : animalClass.animals
                    ) { animal in
                        AnimalRow(
                            animal: animal,
                            settings: settings,
                            conservationData: conservationData
                        )
                    }
                }
            }
        }
    }
}

struct AnimalRow: View {
    let animal: Animal
    let settings: AnimalListSettingsProvider
    
    // A reference type — the view value holds a stable pointer
    let conservationData: ConservationData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(animal.name)
            
            HStack {
                if settings.showScientificNames {
                    Text(animal.scientificName)
                }
                ConservationStatusBadge(status: animal.conservationStatus)
            }
        }
    }
}
// Supporting types stubbed so the example compiles standalone.
@Observable class AnimalListSettingsProvider {
    var sortByConservationStatus = false
    var showScientificNames = true
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

struct Animal: Identifiable {
    var id = UUID()
    var name: String
    var scientificName: String
    var conservationStatus: String
}

struct StatusDefinition {
    var status: String
    var text: String
}

struct Region: Hashable {
    var name: String
}

struct Alert {
    var message: String
}

struct ConservationStatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
    }
}
```
