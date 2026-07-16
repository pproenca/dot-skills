---
title: Store view-created observable models in State not plain properties
tags: state, observation, model-ownership, view-lifecycle
---

## Store view-created observable models in State not plain properties

The wrong default is holding a model the view creates in an ordinary stored property (`private var settings = AnimalListSettingsProvider()`). View structs are ephemeral — SwiftUI recreates them constantly to compare values — so a model stored as a standard property is re-initialized, and its state reset, every time the view struct is initialized. `@State` tells SwiftUI to manage the model's storage on the view's behalf: even when the parent re-evaluates and a new view struct is created, SwiftUI reconnects it to the existing instance, which persists for as long as the view remains in the hierarchy.

**Evidence of violation:** a view struct that initializes a reference-type observable model as the default value of a non-`@State` stored property (`private var settings = AnimalListSettingsProvider()` or `private let settings = AnimalListSettingsProvider()`). PASS: `@State private var settings = AnimalListSettingsProvider()`, or the instance is injected by the parent or read from the environment rather than created here. N/A: the property is injected with no default value (`let settings: AnimalListSettingsProvider`) — ownership then belongs to the parent, which is where this rule applies instead.

**Incorrect (model resets every time the parent re-evaluates):**

```swift
import SwiftUI

@Observable class AnimalListSettingsProvider {
    var sortByConservationStatus = false
    var showScientificNames = true
}

struct Animal: Identifiable {
    var id = UUID()
    var name: String
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

@Observable class AnimalsProvider {
    var allAnimals: [AnimalClass] = []
}

struct AnimalsView: View {
    @Environment(AnimalsProvider.self)
    private var animalsProvider

    var body: some View {
        NavigationStack {
            AnimalList(
                animalClasses: animalsProvider.allAnimals
            )
        }
    }
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]

    // ⚠️ Re-initialized on every AnimalsView body evaluation; user settings reset
    var settings = AnimalListSettingsProvider()

    var body: some View {
        List {
            // ... list rows ...
        }
    }
}
```

**Correct (SwiftUI keeps the same instance alive across struct recreations):**

```swift
import SwiftUI

@Observable class AnimalListSettingsProvider {
    var sortByConservationStatus = false
    var showScientificNames = true
}

struct Animal: Identifiable {
    var id = UUID()
    var name: String
}

struct AnimalClass: Identifiable {
    var id = UUID()
    var name: String
    var animals: [Animal]
}

@Observable class AnimalsProvider {
    var allAnimals: [AnimalClass] = []
}

struct AnimalsView: View {
    @Environment(AnimalsProvider.self)
    private var animalsProvider

    var body: some View {
        NavigationStack {
            AnimalList(
                animalClasses: animalsProvider.allAnimals
            )
        }
    }
}

struct AnimalList: View {
    let animalClasses: [AnimalClass]

    @State private var settings = AnimalListSettingsProvider()

    var body: some View {
        List {
            // ... list rows ...
        }
    }
}
```
