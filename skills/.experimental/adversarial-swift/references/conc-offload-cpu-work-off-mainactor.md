---
title: Mark CPU-bound async work concurrent to leave the main actor
tags: conc, main-actor, offloading, responsiveness, observable
---

## Mark CPU-bound async work concurrent to leave the main actor

The wrong default is believing that wrapping code in `Task { }` or calling it from `.task` moves it to a background thread. A task created in a `@MainActor` context — a SwiftUI view, or an observable class initialized in a view and stored in `@State` (which inherits `@MainActor` isolation) — inherits that isolation, so heavy computation still executes on the main thread and freezes the UI. The book's prescription is to move the heavy step into an async function marked `@concurrent`, which runs it on the global concurrent executor while the awaited result is assigned back on the main actor.

**Evidence of violation:** one of these enumerated CPU-bound operations — decoding a fetched payload, parsing files, image processing, or sorting/transforming a loaded collection whose size is not a fixed compile-time constant — implemented as a plain method of a `@MainActor`-isolated type (explicitly annotated, or an `@Observable` class created in a view and held in `@State`) or inline in a view's `.task` closure, with no offloading marker. PASS: the step is marked `@concurrent`, or an equivalent cited offload — `nonisolated`, a non-main actor, or `Task.detached`. N/A: the async work consists only of `URLSession`/system-API awaits, which offload themselves; also N/A for `@concurrent` specifically on toolchains before Swift 6.2, where the other offloading forms decide PASS.

**Incorrect (decode inherits MainActor isolation — heavy parsing runs on the main thread):**

```swift
struct NationalPark: Decodable { let name: String }
func fetchDataFromNetwork() async throws -> Data { Data() }

@Observable @MainActor final class NationalParkProvider {
    var parks: [NationalPark] = []

    func loadParks() async {
        do {
            let data = try await fetchDataFromNetwork()
            parks = try await decode(data)
        } catch { parks = [] }
    }

    private func decode(_ data: Data) async throws -> [NationalPark] {
        try Task.checkCancellation()
        return try JSONDecoder().decode([NationalPark].self, from: data)
    }
}
```

**Correct (the concurrent attribute opts the decode out of MainActor isolation):**

```swift
struct NationalPark: Decodable { let name: String }
func fetchDataFromNetwork() async throws -> Data { Data() }

@Observable @MainActor final class NationalParkProvider {
    var parks: [NationalPark] = []

    func loadParks() async {
        do {
            let data = try await fetchDataFromNetwork()
            parks = try await decode(data)
        } catch { parks = [] }
    }

    @concurrent private func decode(
        _ data: Data
    ) async throws -> [NationalPark] {
        try Task.checkCancellation()
        return try JSONDecoder().decode([NationalPark].self, from: data)
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Performing long-running operations concurrently”.
