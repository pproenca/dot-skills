---
title: Pass leaf views the values they read not whole models
tags: update, data-dependencies, minimal-interface, reusability
---

## Pass leaf views the values they read not whole models

The wrong default is passing an entire model struct into a small leaf view that renders a single field of it. The whole struct becomes part of the subview's view value, so the subview is re-evaluated whenever any property of the model changes — even fields it never reads — repeating any internal lookups for updates that have no impact on its UI. It also restricts reuse: a component explicitly typed to one model cannot display the same kind of information for other data without refactoring. Passing only the primitive value, ID, or focused `Binding` the view actually uses gives SwiftUI a narrow dependency it can compare cheaply and skip.

**Evidence of violation:** a subview whose stored property is a full model struct while its `body` (plus its computed properties and helpers) reads exactly one property or ID of that model — the fix is to pass that property directly. PASS: the subview accepts the specific value, ID, or `Binding` it uses. N/A: the subview reads two or more distinct properties of the model (the gate fails only the unambiguous single-read case), or the model is an `@Observable` class — reference types get property-level tracking and a cheap pointer comparison, so the broad parameter is not the same hazard.

**Incorrect (any change to any Animal field re-evaluates the habitat section):**

```swift
import SwiftUI

struct AnimalHabitatSection: View {
    // ❌ Potentially harmful: This view now depends on the entire Animal struct
    let animal: Animal
    
    var habitatName: String? {
        HabitatsProvider.habitatName(for: animal.habitatID)
    }
    
    var body: some View {
        if let name = habitatName {
            AnimalInfoSection(header: "Habitat", info: name)
        }
    }
}

class HabitatsProvider {
    static func habitatName(for id: Habitat.ID) -> String? {
        habitatsData
            .flatMap { $0.habitats }.lazy
            .first { $0.id == id }?.name
    }
}
// Supporting types stubbed so the example compiles standalone.
struct Animal: Identifiable {
    var id = UUID()
    var name: String
    var howToSpot: String
    var habitatID: Habitat.ID
}

struct Habitat: Identifiable {
    var id = UUID()
    var name: String
}

struct HabitatGroup {
    var habitats: [Habitat]
}

let habitatsData: [HabitatGroup] = []

struct AnimalInfoSection: View {
    let header: String
    let info: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
            Text(info)
        }
    }
}
```

**Correct (depends only on the one value it renders, and is reusable anywhere a habitat ID exists):**

```swift
import SwiftUI

struct AnimalHabitatSection: View {
    let habitatID: Habitat.ID
    
    var habitatName: String? {
        HabitatsProvider.habitatName(for: habitatID)
    }
    
    var body: some View {
        if let name = habitatName {
            AnimalInfoSection(
                header: "Habitat",
                info: name
            )
        }
    }
}

struct RecordAnimalSightingsButton: View {
    @Binding var showPicker: Bool
    
    var body: some View {
        Button("Record animal sightings") {
            showPicker = true
        }
        .buttonStyle(.borderedProminent)
    }
}

class HabitatsProvider {
    static func habitatName(for id: Habitat.ID) -> String? {
        habitatsData
            .flatMap { $0.habitats }.lazy
            .first { $0.id == id }?.name
    }
}
// Supporting types stubbed so the example compiles standalone.
struct Animal: Identifiable {
    var id = UUID()
    var name: String
    var howToSpot: String
    var habitatID: Habitat.ID
}

struct Habitat: Identifiable {
    var id = UUID()
    var name: String
}

struct HabitatGroup {
    var habitats: [Habitat]
}

let habitatsData: [HabitatGroup] = []

struct AnimalInfoSection: View {
    let header: String
    let info: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
            Text(info)
        }
    }
}
```
