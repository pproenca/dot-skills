---
title: Check for cancellation inside long-running task loops
tags: conc, cancellation, tasks, cooperative-concurrency
---

## Check for cancellation inside long-running task loops

Cancellation in Swift concurrency is cooperative: `task.cancel()` only sets a flag, and work that never consults the flag runs to completion regardless. The wrong default is writing a polling, batching, or retry loop inside a `Task` with no cancellation check, so cancelling the task changes nothing and the app burns CPU, network, and battery on work nobody will consume. Note the trap the book's own example sidesteps with an explicit check: `try? await Task.sleep(...)` swallows the `CancellationError` that `Task.sleep` throws on cancellation, so a `try?`-sleeping loop does not exit through error propagation.

**Evidence of violation:** a loop inside a `Task` or async function that performs repeated work or sleeps per iteration, whose body neither checks `Task.isCancelled` / `try Task.checkCancellation()` nor propagates cancellation through an un-suppressed throwing await — `try? await Task.sleep(...)` suppresses `CancellationError` and does not count as propagation. PASS: an explicit check that exits early, or a `try await` (not `try?`) suspension per iteration whose error propagates out of the loop. N/A: short bounded loops with no suspension, or a task documented at its creation site as not cancellable by design.

**Incorrect (cancel() has no effect — try? swallows CancellationError and nothing checks the flag):**

```swift
enum ExportStatus { case running, finished }
struct ExportService: Sendable { func status(for jobID: String) async -> ExportStatus { .finished } }
let exportService = ExportService()

func pollExportStatus(jobID: String) -> Task<Void, Never> {
    Task {
        while true {
            let status = await exportService.status(for: jobID)
            if status == .finished { break }
            try? await Task.sleep(for: .seconds(2))
        }
    }
}
```

**Correct (the flag is consulted every iteration, cancellation exits early):**

```swift
enum ExportStatus { case running, finished }
struct ExportService: Sendable { func status(for jobID: String) async -> ExportStatus { .finished } }
let exportService = ExportService()

func pollExportStatus(jobID: String) -> Task<Void, Never> {
    Task {
        while !Task.isCancelled {
            let status = await exportService.status(for: jobID)
            if status == .finished { break }
            try? await Task.sleep(for: .seconds(2))
        }
    }
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Utilize task cancellation mechanisms to stop unnecessary work”.
