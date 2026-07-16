---
title: Extract view chunks into standalone structs not computed properties
tags: update, view-composition, viewbuilder, dependency-tracking
---

## Extract view chunks into standalone structs not computed properties

The wrong default is breaking a large `body` into private `@ViewBuilder` computed properties or `func ... -> some View` helpers on the same view. These read cleaner but are not independent nodes in the view tree — they are part of the parent view's own identity, with no independent dependency tracking, so SwiftUI is forced to re-execute their logic on every parent invalidation. Moving the chunk into a standalone view struct defines a boundary in the attribute graph: if the subview's input data has not changed, SwiftUI skips its body — and the work inside it — entirely.

**Evidence of violation:** a computed property or method returning `some View` (with or without `@ViewBuilder`) whose body performs work beyond View and modifier construction — a data lookup, provider call, format call, filter, or sort — declared inside a view that has at least one other change source (`@State`, `@Binding`, `@Environment`, or observable reads). PASS: the same chunk lives in a standalone `struct X: View` receiving only the data it needs, or the helper merely arranges already-stored values with no computation. N/A: the parent view has no other dynamic dependencies, so nothing can invalidate it independently. Precedence when a view-returning member also contains an O(n) transform: report this rule (extract the subview); `update-cache-expensive-derivations` applies only to transforms that would survive the extraction.

**Incorrect (the habitat lookup re-runs on every AnimalDetailView update, including each watchlist toggle):**

```swift
import SwiftUI

struct AnimalDetailView: View {
    let animal: Animal
    
    @Environment(\.watchlist) private var watchlist
    
    private var isWatchlisted: Bool {
        watchlist.contains(animal.id)
    }
    
    @ViewBuilder
    private var habitatSection: some View {
        // ⚠️ This will re-run every time AnimalDetailView updates
        if let name = HabitatsProvider.habitatName(for: animal.habitatID) {
            AnimalInfoSection(header: "Habitat", info: name)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // ... other animal info sections ...
                
                habitatSection
                
                if isWatchlisted {
                    AnimalInfoSection(
                        header: "How to Spot",
                        info: animal.howToSpot
                    )
                }
            }
        }
        .navigationTitle(animal.name)
        .toolbar {
            ToggleWatchListButton(animalID: animal.id)
        }
    }
}

class HabitatsProvider {
    // ... logic to search habitatsData for a matching ID ...
    static func habitatName(for id: Habitat.ID) -> String? {
        habitatsData
            .flatMap { $0.habitats }.lazy
            .first { $0.id == id }?.name
    }
}

struct ToggleWatchListButton: View {
    let animalID: Animal.ID

    var body: some View {
        Button("Toggle watchlist", systemImage: "binoculars") {}
    }
}

extension EnvironmentValues {
    @Entry var watchlist: Set<Animal.ID> = []
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

**Correct (the lookup is skipped while the habitat ID is unchanged):**

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

class HabitatsProvider {
    // ... logic to search habitatsData for a matching ID ...
    static func habitatName(for id: Habitat.ID) -> String? {
        habitatsData
            .flatMap { $0.habitats }.lazy
            .first { $0.id == id }?.name
    }
}

struct AnimalDetailView: View {
    let animal: Animal
    
    @Environment(\.watchlist)
    private var watchlist
    
    private var isWatchlisted: Bool {
        watchlist.contains(animal.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // ... other animal info sections ...
                
                AnimalHabitatSection(habitatID: animal.habitatID)
                
                if isWatchlisted {
                    AnimalInfoSection(
                        header: "How to Spot",
                        info: animal.howToSpot
                    )
                }
            }
        }
        .navigationTitle(animal.name)
        .toolbar {
            ToggleWatchListButton(animalID: animal.id)
        }
    }
}

struct ToggleWatchListButton: View {
    let animalID: Animal.ID

    var body: some View {
        Button("Toggle watchlist", systemImage: "binoculars") {}
    }
}

extension EnvironmentValues {
    @Entry var watchlist: Set<Animal.ID> = []
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
