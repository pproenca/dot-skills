---
title: One Source of Truth Per Piece of State
impact: CRITICAL
impactDescription: eliminates N-way sync bugs — O(1) truth source vs O(N) divergent copies
tags: state, single-source-of-truth, architecture, consistency
---

## One Source of Truth Per Piece of State

Every piece of application state must have exactly ONE authoritative owner. Other views observe or bind to that owner — they never create independent copies. State duplication is the root cause of "my UI shows stale data" bugs. The ViewModel owns domain state, the View owns presentation state (scroll position, focus, etc.).

**Incorrect (two ViewModels each storing the same data independently — drift risk):**

```swift
@Observable
class ProfileViewModel {
    var currentUser: User?

    func loadUser() async {
        currentUser = try? await api.fetchUser()
    }
}

@Observable
class SettingsViewModel {
    // BUG: independent copy of the same user
    // After ProfileViewModel updates, this remains stale
    var currentUser: User?

    func loadUser() async {
        currentUser = try? await api.fetchUser()
    }
}

// Profile shows "Pedro" while Settings still shows "Old Name"
// Two network requests for the same data, two sources of truth
```

**Correct (single shared source — other views observe it):**

```swift
// Single source of truth for user state
@Observable
class UserSession {
    var currentUser: User?

    func loadUser() async {
        currentUser = try? await api.fetchUser()
    }

    func updateName(_ name: String) async {
        currentUser?.name = name
        try? await api.updateUser(currentUser!)
    }
}

// Inject at app root
@main
struct MyApp: App {
    @State private var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(userSession)
        }
    }
}

// Both views observe the SAME instance
struct ProfileView: View {
    @Environment(UserSession.self) var session

    var body: some View {
        Text(session.currentUser?.name ?? "Loading...")
    }
}

struct SettingsView: View {
    @Environment(UserSession.self) var session

    var body: some View {
        Text(session.currentUser?.name ?? "Loading...")
        // Always in sync with ProfileView — same source
    }
}
```

**State ownership guidelines:**
- Domain state (user, cart, settings) — owned by a shared `@Observable` class
- Presentation state (scroll position, focus, sheet visibility) — owned by the view via `@State`
- Derived state (filtered list, computed totals) — computed properties, never stored separately

Reference: [Clean Architecture for SwiftUI — nalexn.github.io](https://nalexn.github.io/clean-architecture-swiftui/)
