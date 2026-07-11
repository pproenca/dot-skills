---
title: Wrap environment closures in callAsFunction action structs
tags: update, environment, callasfunction, dismiss-action
---

## Wrap environment closures in callAsFunction action structs

The wrong default is declaring a bare function type as a custom environment value (`@Entry var addToWatchlist: (UUID) -> Void`). SwiftUI cannot compare closures for equality, so when a raw closure is passed directly into the environment the framework cannot determine whether the value actually changed, which leads to views consuming it being invalidated far more often than expected. Wrapping the closure in a struct with `callAsFunction()` — the pattern SwiftUI itself uses for `DismissAction` and `OpenURLAction` — provides a stable type the environment can handle efficiently, while call sites still read like plain function calls.

**Evidence of violation:** an `EnvironmentValues` extension declaring an `@Entry` property (or a legacy `EnvironmentKey`) whose type is a bare function type. PASS: the closure is wrapped in a struct exposing `callAsFunction()`. N/A: no custom closure-shaped environment values exist in the target.

**Incorrect (the environment cannot tell whether the closure changed):**

```swift
import SwiftUI

extension EnvironmentValues {
    @Entry var addToWatchlist: (UUID) -> Void = { _ in }
}
```

**Correct (a stable action type, called like a function):**

```swift
import SwiftUI

struct AddToWatchlistAction {
    private let action: (UUID) -> Void

    init(action: @escaping (UUID) -> Void) {
        self.action = action
    }

    func callAsFunction(_ animalID: UUID) {
        action(animalID)
    }
}

extension EnvironmentValues {
    @Entry var addToWatchlist = AddToWatchlistAction(action: { _ in })
}

struct WatchlistButton: View {
    let animalID: UUID

    @Environment(\.addToWatchlist)
    private var addToWatchlist

    var body: some View {
        Button("Add to watchlist") {
            addToWatchlist(animalID)
        }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Passing data through the Environment”.
