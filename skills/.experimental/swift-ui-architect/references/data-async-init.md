---
title: Never Perform Async Work in Init
impact: MEDIUM
impactDescription: eliminates N redundant network requests per parent re-render cycle
tags: data, init, async, task, main-thread
---

## Never Perform Async Work in Init

`@Observable` class initializers run synchronously on the main thread. Performing async work (network calls, database queries) in init blocks the UI and runs every time the parent view re-evaluates and recreates the object. Spawning a detached `Task {}` inside init avoids blocking but creates an unstructured task that cannot be cancelled when the view disappears. Move all async initialization to a `load()` method called from `.task {}`.

**Incorrect (Task spawned in init — runs on every parent re-render, unstructured):**

```swift
@Observable
class UserProfileViewModel {
    var user: User?
    var isLoading = false

    init(userId: String) {
        // This init runs every time the PARENT view's body re-evaluates
        // if the ViewModel isn't held in @State
        Task {
            // Detached, unstructured Task — not tied to any view lifecycle
            // Cannot be cancelled when the view disappears
            isLoading = true
            user = try? await UserService().fetchUser(id: userId)
            isLoading = false
        }
    }
}

struct ProfileView: View {
    let userId: String

    var body: some View {
        // Without @State, this creates a NEW ViewModel on every body evaluation
        // Each new ViewModel spawns another Task in init
        let viewModel = UserProfileViewModel(userId: userId)
        ProfileContent(viewModel: viewModel)
    }
}

// Problems:
// 1. Parent view re-renders 5 times → 5 ViewModel inits → 5 network requests
// 2. None of these Tasks are cancelled when the view disappears
// 3. All 5 responses arrive and update state on a deallocated object
// 4. Main thread blocked during synchronous init work before Task spawns
```

**Correct (explicit load() method called from .task — structured, cancellable):**

```swift
@Observable
class UserProfileViewModel {
    var user: User?
    var isLoading = false
    private let userId: String
    private let userService: any UserServiceProtocol

    init(userId: String, userService: any UserServiceProtocol) {
        // Init is synchronous and fast — only stores values
        self.userId = userId
        self.userService = userService
        // NO async work, NO Task creation
    }

    func load() async {
        // Called from .task — structured concurrency, auto-cancellable
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            user = try await userService.fetchUser(id: userId)
        } catch {
            // Handle error (CancellationError is automatically thrown on cancel)
            if !Task.isCancelled {
                // Only handle non-cancellation errors
                self.user = nil
            }
        }
    }
}

struct ProfileView: View {
    @State var viewModel: UserProfileViewModel
    // @State ensures the ViewModel survives parent re-renders

    var body: some View {
        ProfileContent(viewModel: viewModel)
            .task {
                // Structured: cancelled when view disappears
                // Runs once when view appears (not on every parent re-render)
                await viewModel.load()
            }
    }
}
```

**Key rules:**
- `init()` must be synchronous, fast, and side-effect free — store values only
- All async work lives in explicit methods (`load()`, `refresh()`, `search()`)
- `.task {}` provides structured concurrency with automatic cancellation
- `@State` on the ViewModel prevents recreation on parent re-renders

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
