---
title: Replace @EnvironmentObject with @Environment
impact: CRITICAL
impactDescription: compile-time safety, eliminates runtime crashes from missing injection
tags: api, environment, observable, dependency-injection, migration
---

## Replace @EnvironmentObject with @Environment

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

@EnvironmentObject provides no compile-time guarantee that the object was injected. If a parent view forgets to call .environmentObject(), the app crashes at runtime with a vague error. With @Observable classes, you can inject via .environment() and access via @Environment, which surfaces missing dependencies as compile-time errors. This eliminates an entire category of runtime crashes in production.

**Incorrect (runtime crash if injection is missing):**

```swift
class UserSession: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
}

struct ProfileView: View {
    @EnvironmentObject var session: UserSession
    // Crashes at runtime if .environmentObject(session) is missing

    var body: some View {
        if let user = session.currentUser {
            Text(user.displayName)
        }
    }
}

struct AppView: View {
    @StateObject private var session = UserSession()

    var body: some View {
        ProfileView()
            .environmentObject(session)
    }
}
```

**Correct (compile-time safety with @Environment):**

```swift
@Observable
class UserSession {
    var currentUser: User?
    var isAuthenticated: Bool = false
}

struct ProfileView: View {
    @Environment(UserSession.self) var session
    // Compiler verifies the type is registered in the environment

    var body: some View {
        if let user = session.currentUser {
            Text(user.displayName)
        }
    }
}

struct AppView: View {
    @State private var session = UserSession()

    var body: some View {
        ProfileView()
            .environment(session)
    }
}
```

Reference: [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
