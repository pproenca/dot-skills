---
title: Wrap environment closures in callAsFunction action structs
tags: state, environment, callasfunction, dismiss-action
---

## Wrap environment closures in callAsFunction action structs

The wrong default is declaring a bare function type as a custom environment value (`@Entry var addToWatchlist: (Animal.ID) -> Void`). SwiftUI cannot compare closures for equality, so when a raw closure is passed directly into the environment the framework cannot determine whether the value actually changed, which leads to views consuming it being invalidated far more often than expected. Wrapping the closure in a struct with `callAsFunction()` — the pattern SwiftUI itself uses for `DismissAction` and `OpenURLAction` — provides a stable type the environment can handle efficiently, while call sites still read like plain function calls.

**Evidence of violation:** an `EnvironmentValues` extension declaring an `@Entry` property (or a legacy `EnvironmentKey`) whose type is a bare function type. PASS: the closure is wrapped in a struct exposing `callAsFunction()`. N/A: no custom closure-shaped environment values exist in the target.

**Incorrect (the environment cannot tell whether the closure changed):**

```swift
import SwiftUI

struct Animal: Identifiable {
    var id = UUID()
    var name: String
}

extension EnvironmentValues {
    // ❌ Potentially harmful: Can causes frequent view re-evaluations
    @Entry var addToWatchlist: (Animal.ID) -> Void = { _ in }
}
```

**Correct (a stable action type, called like a function):**

```swift
import SwiftUI

struct Animal: Identifiable {
    var id = UUID()
    var name: String
}

@Observable class WatchlistProvider {
    var watchlist: Set<Animal.ID> = []

    func addToWatchlist(_ animalID: Animal.ID) {
        watchlist.insert(animalID)
    }
}

struct AddToWatchListAction {
    private let action: (Animal.ID) -> Void

    init(action: @escaping (Animal.ID) -> Void) {
        self.action = action
    }

    func callAsFunction(_ animalID: Animal.ID) {
        action(animalID)
    }
}

extension EnvironmentValues {
    @Entry var addToWatchlist = AddToWatchListAction(action: { _ in })
}

@main
struct AotearoaExplorerApp: App {
    @State private var watchlistProvider = WatchlistProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.addToWatchlist,
                    AddToWatchListAction(
                        action: watchlistProvider.addToWatchlist
                    )
                )
        }
    }
}

struct ContentView: View {
    var body: some View {
        AnimalDetailView(animalID: Animal.ID())
    }
}

struct AnimalDetailView: View {
    let animalID: Animal.ID

    @Environment(\.addToWatchlist)
    private var addToWatchlist

    var body: some View {
        ScrollView {
            // ... animal detail subviews ...
            Text("Animal details")
        }
        .toolbar {
            Button("Add to watchlist", systemImage: "binoculars") {
                addToWatchlist(animalID)
            }
        }
    }
}
```
