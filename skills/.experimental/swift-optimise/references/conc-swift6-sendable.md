---
title: Adopt Sendable and Swift 6 Strict Concurrency
impact: CRITICAL
impactDescription: compile-time data race detection eliminates an entire class of intermittent crashes that affect 1-5% of concurrent code paths
tags: conc, sendable, swift6, concurrency, migration, data-race
---

## Adopt Sendable and Swift 6 Strict Concurrency

Swift 6 strict concurrency checking turns data races into compile errors. Types that cross isolation boundaries (passed between actors, captured in `@Sendable` closures, or sent to `Task` blocks) must conform to `Sendable`. Silencing warnings with `@unchecked Sendable` or `nonisolated(unsafe)` without understanding the implication reintroduces the data races the compiler is trying to prevent.

**Incorrect (silencing the compiler without ensuring safety):**

```swift
// Marking a mutable class as @unchecked Sendable hides the data race
class AppSettings: @unchecked Sendable {
    var theme: Theme = .system
    var fontSize: Int = 14
    // Mutable properties accessed from multiple threads -- data race
}

// nonisolated(unsafe) on a mutable global
nonisolated(unsafe) var sharedCache: [String: Data] = [:]
```

**Correct (using proper isolation to ensure safety):**

```swift
// Option 1: Actor -- compiler-enforced mutual exclusion
actor AppSettings {
    var theme: Theme = .system
    var fontSize: Int = 14
}

// Option 2: Sendable struct -- value semantics guarantee safety
struct AppTheme: Sendable {
    let theme: Theme
    let fontSize: Int
}

// Option 3: MainActor isolation for UI-bound singletons
@Observable
@MainActor
final class AppSettings {
    var theme: Theme = .system
    var fontSize: Int = 14
}
```

**When `@unchecked Sendable` is legitimate:**

```swift
// Thread-safe wrapper with internal synchronization
final class AtomicCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Int = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        _value += 1
    }
}
```

**When `nonisolated(unsafe)` is acceptable:**

```swift
// Truly immutable after initialization (e.g., app launch constants)
// Safe because the value never changes after first assignment
nonisolated(unsafe) let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
```

**Migration strategy:**
1. Enable strict concurrency per-target: `Swift Compiler > Upcoming Features > StrictConcurrency`
2. Fix warnings category by category: global state → Sendable conformance → actor isolation
3. Use `@unchecked Sendable` only for types with provably-safe internal synchronization
4. Use `nonisolated(unsafe)` only for truly immutable globals

**Swift 6.2 note:** `nonisolated(nonsending)` becomes the default for async functions, meaning nonisolated async functions no longer need explicit `@Sendable` closures in many cases.

Reference: [Swift 6 Migration Guide](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/commonproblems/)
