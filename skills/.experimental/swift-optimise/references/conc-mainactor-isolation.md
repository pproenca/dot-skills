---
title: Use @MainActor Instead of DispatchQueue.main
impact: MEDIUM-HIGH
impactDescription: compile-time thread safety, prevents data races
tags: conc, mainactor, dispatch, thread-safety, swift-concurrency
---

## Use @MainActor Instead of DispatchQueue.main

`DispatchQueue.main.async` provides only a runtime guarantee of main-thread execution. If a developer forgets the dispatch, the code still compiles but silently introduces a data race. `@MainActor` moves this guarantee to compile time -- the compiler rejects any non-isolated call site that tries to invoke main-actor-isolated code synchronously. This is essential under Swift 6 strict concurrency checking, where data races become compile errors.

**Incorrect (runtime-only main thread dispatch, easy to forget):**

```swift
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var errorMessage: String?

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
            errorMessage = error.localizedDescription
        }
    }
}
```

Reference: [MainActor](https://developer.apple.com/documentation/swift/mainactor)
