---
title: Capture self weakly in closures the instance itself retains
tags: conc, retain-cycles, memory, closures, timers
---

## Capture self weakly in closures the instance itself retains

The wrong default is referencing `self` strongly inside an escaping closure that the same instance stores — a repeating `Timer` kept in a property, a stored handler, an observation token. The instance retains the closure and the closure retains the instance, so `deinit` never runs, the timer never invalidates, and the object leaks for the life of the process. The source's timer example captures `[weak self]` for exactly this reason, and since Swift 5.8 the unwrapped `self` can be used implicitly afterward, so the fix costs no verbosity.

**Evidence of violation:** a closure that references `self` with no `[weak self]` (or `[unowned self]`) capture list, where the closure — directly, or via the `Timer`/subscription/handler it configures — is stored in a property of that same class instance. PASS: `[weak self]` with `guard let self else { return }` (implicit `self` after the unwrap is fine on Swift 5.8+). N/A: non-escaping closures (e.g. `map`, `forEach`), closures the instance does not retain, and value-type (`struct`) contexts, where no cycle can form.

**Incorrect (instance retains timer, timer closure retains instance — deinit never runs):**

```swift
final class PeriodicSyncScheduler {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 30, repeats: true
        ) { _ in
            self.syncPendingChanges()
        }
    }

    private func syncPendingChanges() { /* upload queued edits */ }

    deinit { timer?.invalidate() } // unreachable: the cycle keeps self alive
}
```

**Correct (weak capture breaks the cycle, implicit self after the unwrap):**

```swift
final class PeriodicSyncScheduler {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 30, repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            syncPendingChanges()
        }
    }

    private func syncPendingChanges() { /* upload queued edits */ }

    deinit { timer?.invalidate() }
}
```

Reference: expert Swift reference (2025), “Utilize implicit self references in closures”.
