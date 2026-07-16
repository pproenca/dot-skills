---
title: Fan out over runtime collections with a task group not unstructured tasks
tags: conc, taskgroup, structured-concurrency, data-races
---

## Fan out over runtime collections with a task group not unstructured tasks

The wrong default for a runtime-sized fan-out is spawning an unstructured `Task {}` per element inside a loop and merging results through shared mutable state. The spawned tasks outlive the function — no join point, no cancellation propagation — so the aggregate is read before they finish, and the shared-state merge is a data race that minimal-checking targets compile without complaint. `withThrowingTaskGroup` joins every child, propagates cancellation to all of them, and aggregates safely through the group's async sequence.

**Evidence of violation:** a loop over a runtime collection whose body creates `Task {}` or `Task.detached {}` per element, with results merged via captured mutable state (a reference-type box, an appended array, a completion counter) and the aggregate consumed after the loop. PASS: per-element work runs inside `withTaskGroup`/`withThrowingTaskGroup`, or a fixed small arity uses `async let`. N/A: no per-element task spawning in the target, or the spawned tasks are genuine fire-and-forget whose results are never consumed (an unstructured-task-lifetime concern outside this rule).

**Incorrect (tasks are never joined — the sum is read while they still run, through a racy shared box):**

```swift
import Foundation

final class SizeCollector {
    var sizes: [Int] = []
}

func totalFileSize(at path: String) async throws -> Int {
    let urls = try FileManager.default.contentsOfDirectory(
        atPath: path
    )
        .map {
            URL(filePath: path)
                .appendingPathComponent($0)
        }

    let collector = SizeCollector()
    for url in urls where url.isFileURL {
        Task {
            let size = (try? Data(contentsOf: url))?.count ?? 0
            collector.sizes.append(size)
        }
    }

    // No join point — the tasks may still be running here
    return collector.sizes.reduce(0, +)
}
```

**Correct (the group joins every child and aggregates through its async sequence):**

```swift
import Foundation

func totalFileSize(at path: String) async throws -> Int {
    let urls = try FileManager.default.contentsOfDirectory(
        atPath: path
    )
        .map {
            URL(filePath: path)
                .appendingPathComponent($0)
        }

    return try await withThrowingTaskGroup(
        of: Int.self
    ) { group in
        for url in urls where url.isFileURL {
            group.addTask {
                (try? Data(contentsOf: url))?.count ?? 0
            }
        }

        var total = 0
        for try await size in group {
            total += size
        }
        return total
    }
}
```
