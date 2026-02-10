---
title: Use @MainActor Instead of DispatchQueue.main
impact: CRITICAL
impactDescription: compile-time thread safety prevents data races that cause crashes in ~5% of async UI updates without dispatch
tags: conc, mainactor, dispatch, thread-safety, swift-concurrency
---

## Use @MainActor Instead of DispatchQueue.main

`DispatchQueue.main.async` provides only a runtime guarantee of main-thread execution. If a developer forgets the dispatch, the code still compiles but silently introduces a data race. `@MainActor` moves this guarantee to compile time -- the compiler rejects any non-isolated call site that tries to invoke main-actor-isolated code synchronously. This is essential under Swift 6 strict concurrency checking, where data races become compile errors.

**Incorrect (runtime-only main thread dispatch, easy to forget):**

```swift
@Observable
class ProfileViewModel {
    var profile: UserProfile?
    var errorMessage: String?

    func loadProfile(userID: String) async {
        do {
            let result = try await APIClient.fetchProfile(userID: userID)
            DispatchQueue.main.async {
                self.profile = result
            }
        } catch {
            // Easy to forget DispatchQueue.main here -- silent data race
            self.errorMessage = error.localizedDescription
        }
    }
}
```

**Correct (compile-time main thread guarantee):**

```swift
@MainActor
@Observable
class ProfileViewModel {
    var profile: UserProfile?
    var errorMessage: String?

    func loadProfile(userID: String) async {
        do {
            // Already on MainActor -- assignment is safe
            profile = try await APIClient.fetchProfile(userID: userID)
        } catch {
            // Compiler guarantees this runs on MainActor too
            errorMessage = error.localizedDescription
        }
    }
}
```

**Isolating specific methods instead of the whole class:**

```swift
@Observable
class DataProcessor {
    var results: [ProcessedItem] = []

    // Heavy computation stays off the main thread
    func process(items: [RawItem]) async -> [ProcessedItem] {
        await withTaskGroup(of: ProcessedItem.self) { group in
            for item in items {
                group.addTask { ProcessedItem(from: item) }
            }
            return await group.reduce(into: []) { $0.append($1) }
        }
    }

    // Only the UI update is isolated to MainActor
    @MainActor
    func updateUI(with items: [ProcessedItem]) {
        results = items
    }
}
```

Reference: [MainActor](https://developer.apple.com/documentation/swift/mainactor)
