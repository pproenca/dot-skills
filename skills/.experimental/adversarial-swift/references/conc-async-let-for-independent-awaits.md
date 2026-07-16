---
title: Run independent awaits concurrently with async let
tags: conc, async-let, latency, structured-concurrency
---

## Run independent awaits concurrently with async let

The wrong default is awaiting independent async operations one after another — `let flowers = try await fetchFlowers()` then `let pollinators = try await fetchPollinators()` — when neither result feeds the other. Total latency becomes the sum of the operations instead of the max of them; the code compiles clean and passes tests, so nothing ever flags the user-visible slowdown. `async let` starts both operations immediately and suspends only where the results are consumed.

**Evidence of violation:** two or more sequential `await` expressions in one function where no later expression consumes a value produced by an earlier one (no data dependency) and no ordering-sensitive code separates them. PASS: a data dependency links the awaits, an explicit ordering constraint is stated in code or a comment (rate limit, transactional ordering), the awaits target the same actor-isolated mutable resource, or the independent operations already run via `async let` or a task group. N/A: no function in the target contains two or more awaits.

**Incorrect (sequential awaits — total time is fetchFlowers plus fetchPollinators):**

```swift
struct Flower { let name: String }
struct Pollinator { let name: String }
func fetchFlowers() async throws -> [Flower] { [] }
func fetchPollinators() async throws -> [Pollinator] { [] }

func loadGardenData() async {
    do {
        let loadedFlowers = try await fetchFlowers()
        let loadedPollinators = try await fetchPollinators()

        print("""
        Loaded \(loadedFlowers.count) flowers \
        and \(loadedPollinators.count) pollinators.
        """)
    } catch {
        print("Failed to load data: \(error)")
    }
}
```

**Correct (async let starts both at once — total time is the slower of the two):**

```swift
struct Flower { let name: String }
struct Pollinator { let name: String }
func fetchFlowers() async throws -> [Flower] { [] }
func fetchPollinators() async throws -> [Pollinator] { [] }

func loadGardenData() async {
    async let flowers = fetchFlowers()
    async let pollinators = fetchPollinators()

    do {
        let (loadedFlowers, loadedPollinators) =
            try await (flowers, pollinators)

        print("""
        Loaded \(loadedFlowers.count) flowers \
        and \(loadedPollinators.count) pollinators.
        """)
    } catch {
        print("Failed to load data: \(error)")
    }
}
```
