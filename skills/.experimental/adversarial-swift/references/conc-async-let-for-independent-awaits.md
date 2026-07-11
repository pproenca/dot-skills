---
title: Run independent async operations concurrently with async let
tags: conc, async-let, parallelism, latency, task-group
---

## Run independent async operations concurrently with async let

The wrong default is awaiting independent operations one after another — `let a = try await fetchA(); let b = try await fetchB()` — which serializes work that has no reason to wait, adding the full latency of each call to the total. With `async let`, each operation begins the moment it is declared and Swift only suspends when the results are awaited, so independent fetches overlap for free. When the number of operations is dynamic, `withTaskGroup` is the equivalent tool.

**Evidence of violation:** two or more sequential `await` calls in one function where the later call's arguments and control flow reference nothing produced by the earlier call. A claimed dependency must be cited per leg — name the produced value the later call consumes, or the ordering constraint (e.g. actor-serialized writes) that forces the sequence; a dependency asserted without citable evidence does not excuse the serialization. PASS: `async let` for a fixed set of independent operations, `withTaskGroup` / `withThrowingTaskGroup` for a dynamic set. N/A: every sequential await consumes a value or ordering guarantee from the one before it.

**Incorrect (independent fetches serialized — total latency is the sum):**

```swift
struct GardenSnapshot { let flowers: [String]; let pollinators: [String] }
func fetchFlowers() async throws -> [String] { [] }
func fetchPollinators() async throws -> [String] { [] }

func loadGardenData() async throws -> GardenSnapshot {
    let flowers = try await fetchFlowers()
    let pollinators = try await fetchPollinators() // uses nothing from flowers
    return GardenSnapshot(flowers: flowers, pollinators: pollinators)
}
```

**Correct (both start immediately, suspension happens only at the combined await):**

```swift
struct GardenSnapshot { let flowers: [String]; let pollinators: [String] }
func fetchFlowers() async throws -> [String] { [] }
func fetchPollinators() async throws -> [String] { [] }

func loadGardenData() async throws -> GardenSnapshot {
    async let flowers = fetchFlowers()
    async let pollinators = fetchPollinators()
    let (loadedFlowers, loadedPollinators) =
        try await (flowers, pollinators)
    return GardenSnapshot(
        flowers: loadedFlowers,
        pollinators: loadedPollinators
    )
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Start multiple asynchronous operations at the same time”.
