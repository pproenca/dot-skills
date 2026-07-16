---
title: Mark CPU-bound async work concurrent to leave the main actor
tags: task, main-actor, offloading, cancellation, observable
---

## Mark CPU-bound async work concurrent to leave the main actor

The wrong default is believing that wrapping code in `Task { }` or calling it from `.task` moves it to a background thread. A task created in a `@MainActor` context inherits that isolation — and an `@Observable` class initialized within a SwiftUI view and stored in `@State` inherits `@MainActor` isolation by default — so the "background" decode still executes on the main thread and freezes the UI. The source's foil differs from its fix by exactly one attribute: marking the heavy step `@concurrent` runs it on the global concurrent executor, while the awaited result is assigned back on the main actor. Because Swift cancellation is cooperative, the offloaded function should also call `try Task.checkCancellation()` before expensive phases or inside loops, so the cancellation that `.task` signals on view departure actually stops the work instead of letting it run to completion for nobody.

**Evidence of violation:** one of these enumerated CPU-bound operations — decoding a fetched payload, parsing files, image processing, or sorting/transforming a loaded collection whose size is not a fixed compile-time constant — implemented as a plain method of a `@MainActor`-isolated type (explicitly annotated, or an `@Observable` class created in a view and held in `@State`) or inline in a view's `.task` closure, with no offloading marker. PASS: the step is marked `@concurrent`, or an equivalent cited offload — `nonisolated`, a non-main actor, or `Task.detached` — and, when the offloaded body contains a loop or multiple expensive phases, it checks cancellation via `try Task.checkCancellation()` or `Task.isCancelled`. Async work consisting only of `URLSession`/system-API awaits never fails this rule — Foundation offloads those itself. N/A: no CPU-bound work in observables or view tasks. On toolchains before Swift 6.2 the `@concurrent` spelling is N/A, but the offloading requirement still decides the rule through the equivalents.

**Incorrect (decode inherits MainActor isolation — heavy parsing runs on the main thread):**

```swift
import SwiftUI

struct NationalPark: Identifiable, Decodable {
    let id: Int
    let name: String
}

struct ParkRow: View {
    let park: NationalPark

    var body: some View {
        Text(park.name)
    }
}

struct NationalParkListView: View {
    @State private var provider = NationalParkProvider()

    var body: some View {
        List(provider.parks) { park in
            ParkRow(park: park)
        }
        .overlay {
            if provider.isProcessing {
                ProgressView()
            }
        }
        .task {
            await provider.loadParks()
        }
    }
}

@Observable @MainActor class NationalParkProvider {
    var parks: [NationalPark] = []
    var isProcessing = false

    func loadParks() async {
        isProcessing = true

        do {
            let data = try await fetchDataFromNetwork()
            parks = try await decode(data)
        } catch {
            // ... handle errors ...
        }

        isProcessing = false
    }

    private func fetchDataFromNetwork() async throws -> Data {
        // ... fetch data from a server ...
        Data()
    }

    // ⚠️ Executes on the main thread
    private func decode(_ data: Data) async throws -> [NationalPark] {
        try Task.checkCancellation()

        // ... decode data ...
        return try JSONDecoder().decode([NationalPark].self, from: data)
    }
}
```

**Correct (the concurrent attribute opts the decode out of MainActor isolation):**

```swift
import SwiftUI

struct NationalPark: Identifiable, Decodable {
    let id: Int
    let name: String
}

struct ParkRow: View {
    let park: NationalPark

    var body: some View {
        Text(park.name)
    }
}

struct NationalParkListView: View {
    @State private var provider = NationalParkProvider()

    var body: some View {
        List(provider.parks) { park in
            ParkRow(park: park)
        }
        .overlay {
            if provider.isProcessing {
                ProgressView()
            }
        }
        .task {
            await provider.loadParks()
        }
    }
}

@Observable @MainActor class NationalParkProvider {
    var parks: [NationalPark] = []
    var isProcessing = false

    func loadParks() async {
        isProcessing = true

        do {
            let data = try await fetchDataFromNetwork()
            parks = try await decode(data)
        } catch {
            // ... handle errors ...
        }

        isProcessing = false
    }

    private func fetchDataFromNetwork() async throws -> Data {
        // ... fetch data from a server ...
        Data()
    }

    @concurrent private func decode(_ data: Data) async throws -> [NationalPark] {
        try Task.checkCancellation()

        // ... decode data ...
        return try JSONDecoder().decode([NationalPark].self, from: data)
    }
}
```
