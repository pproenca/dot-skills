---
title: Check for cancellation inside long-running loops
tags: conc, cancellation, task-lifecycle
---

## Check for cancellation inside long-running loops

The wrong default is writing a multi-iteration loop inside a cancellable task with no `Task.isCancelled` guard and no `try Task.checkCancellation()`, so cancelling the task changes nothing — the loop runs to completion, burning CPU and network for a consumer that is gone. The trap compounds with `try? await Task.sleep(...)`: `try?` swallows the `CancellationError` the sleep throws on cancellation, silently discarding the one built-in signal that would have stopped the loop.

**Evidence of violation:** a `for`/`while` loop inside a `Task {}` or async function performing per-iteration work, whose body contains neither a `Task.isCancelled` guard nor `try Task.checkCancellation()`, in code where the task is cancellable (a handle to it exists, or it is a child of a cancellable scope). `try? await Task.sleep(...)` — or any `try?`/`try!`-wrapped throwing await — does NOT count as cancellation propagation, because `try?` swallows the `CancellationError`; a loop whose only suspension point is a `try?`-wrapped sleep runs to completion after `cancel()`. PASS: the loop checks `Task.isCancelled` or calls `try Task.checkCancellation()` per iteration, or every iteration `try await`s (plain `try`, propagating) a call that rethrows `CancellationError`. N/A: the target has no multi-iteration loops in cancellable async contexts.

**Incorrect (cancel() has no effect — no check, and try? swallows the CancellationError):**

```swift
func performLongRunningTask() async {
    let task = Task {
        for i in 1...10 {
            print("Processing \(i)")

            // Sleep for 1 second
            try? await Task.sleep(for: .seconds(1))
        }
        print("Task completed successfully")
    }

    Task {
        // Sleep for 3 seconds
        try? await Task.sleep(for: .seconds(3))

        task.cancel()
        print("Called cancel on the task")
    }
}
```

**Correct (a per-iteration guard stops the loop as soon as the task is cancelled):**

```swift
func performLongRunningTask() async {
    let task = Task {
        for i in 1...10 {
            guard !Task.isCancelled else {
                print("Task was cancelled!")
                return
            }

            print("Processing \(i)")

            // Sleep for 1 second
            try? await Task.sleep(for: .seconds(1))
        }
        print("Task completed successfully")
    }

    Task {
        // Sleep for 3 seconds
        try? await Task.sleep(for: .seconds(3))

        task.cancel()
        print("Called cancel on the task")
    }
}
```
