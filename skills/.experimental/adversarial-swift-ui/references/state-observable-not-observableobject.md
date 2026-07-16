---
title: Use the Observable macro instead of ObservableObject for new models
tags: state, observation, observable-macro, swiftui
---

## Use the Observable macro instead of ObservableObject for new models

The wrong default is reaching for the legacy `ObservableObject` protocol with `@Published` properties, consumed through `@StateObject`/`@ObservedObject`. When a view reads at least one `@Published` property of an `ObservableObject`, its body re-evaluates when *any* of the `@Published` properties change — even ones the view never reads. The `@Observable` macro tracks dependencies at the property level, so a view re-evaluates only when a property it actually reads is modified, eliminating this over-invalidation across every observer.

**Evidence of violation:** newly written code containing an `ObservableObject` conformance, a `@Published` property, `@StateObject`, or `@ObservedObject`. PASS: models declared with `@Observable` and consumed via `@State`, `@Bindable`, `@Environment`, or a plain property. N/A: the deployment target is below iOS 17/macOS 14 (the Observation framework's floor), or a comment cites a concrete interop constraint (e.g. a third-party SDK type that is an `ObservableObject`). A carve-out asserted without citable evidence fails closed. Pre-existing legacy models merely touched by the diff are N/A; models the diff introduces are in scope.

**Incorrect (every row re-runs when any published property changes):**

```swift
import SwiftUI

struct Animal: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var scientificName: String
    var conservationStatus: String
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

struct ConservationStatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
    }
}

// ❌ Potentially harmful: Causes dependent views to re-evaluate when any property changes
class AnimalListSettingsProvider: ObservableObject {
    @Published var sortByConservationStatus = false
    @Published var showScientificNames = true
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]
    @StateObject private var settings = AnimalListSettingsProvider()

    var body: some View {
        List {
            ForEach(animalClasses) { animalClass in
                Section(animalClass.name) {
                    ForEach(
                        settings.sortByConservationStatus
                        ? animalClass.animals.sorted(
                            using: KeyPathComparator(\.conservationStatus)
                        )
                        : animalClass.animals
                    ) { animal in
                        NavigationLink(value: animal) {
                            AnimalRow(
                                animal: animal,
                                settings: settings
                            )
                        }
                    }
                }
            }
        }
    }
}

struct AnimalRow: View {
    let animal: Animal
    @ObservedObject var settings: AnimalListSettingsProvider

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
```

**Correct (views re-evaluate only for properties they read):**

```swift
import SwiftUI

struct Animal: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var scientificName: String
    var conservationStatus: String
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

struct ConservationStatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
    }
}

@Observable class AnimalListSettingsProvider {
    var sortByConservationStatus = false
    var showScientificNames = true
}

struct SettingsView: View {
    @Bindable var settings: AnimalListSettingsProvider

    var body: some View {
        NavigationStack {
            Form {
                // ... settings form ...
                Toggle(
                    "Sort by conservation status",
                    isOn: $settings.sortByConservationStatus
                )
                Toggle(
                    "Show scientific names",
                    isOn: $settings.showScientificNames
                )
            }
        }
    }
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]

    @State private var settings = AnimalListSettingsProvider()

    // ... other view properties ...
    @State private var showSettings = false

    var body: some View {
        List {
            ForEach(animalClasses) { animalClass in
                Section(animalClass.name) {
                    ForEach(
                        settings.sortByConservationStatus
                        ? animalClass.animals.sorted(
                            using: KeyPathComparator(\.conservationStatus)
                        )
                        : animalClass.animals
                    ) { animal in
                        NavigationLink(value: animal) {
                            AnimalRow(
                                animal: animal,
                                settings: settings
                            )
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
    }
}

struct AnimalRow: View {
    let animal: Animal
    let settings: AnimalListSettingsProvider

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
```
