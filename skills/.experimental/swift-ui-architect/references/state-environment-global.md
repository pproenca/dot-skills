---
title: Use @Environment for App-Wide Shared Dependencies
impact: MEDIUM-HIGH
impactDescription: eliminates prop drilling across 5+ levels of view hierarchy
tags: state, environment, dependency, shared, global
---

## Use @Environment for App-Wide Shared Dependencies

For dependencies needed across many views (authentication state, theme, locale, analytics), inject via `@Environment` with custom `EnvironmentKey`. This eliminates prop drilling and keeps view signatures clean. Use the `@Entry` macro (Xcode 16) to simplify custom `EnvironmentKey` definitions.

**Incorrect (prop drilling through 5 levels — fragile and verbose):**

```swift
// authManager passed through every intermediate view
struct AppRoot: View {
    @State var authManager = AuthManager()

    var body: some View {
        TabView {
            HomeTab(authManager: authManager)
            ProfileTab(authManager: authManager)
        }
    }
}

struct HomeTab: View {
    let authManager: AuthManager  // doesn't use it, just passes it down

    var body: some View {
        NavigationStack {
            HomeScreen(authManager: authManager)
        }
    }
}

struct HomeScreen: View {
    let authManager: AuthManager  // doesn't use it, just passes it down

    var body: some View {
        FeedView(authManager: authManager)
    }
}

struct FeedView: View {
    let authManager: AuthManager  // finally uses it

    var body: some View {
        if authManager.isLoggedIn {
            Text("Welcome, \(authManager.currentUser?.name ?? "")")
        }
    }
}
```

**Correct (@Environment injection — clean view signatures, no drilling):**

```swift
// Define the EnvironmentKey with @Entry macro (Xcode 16+)
extension EnvironmentValues {
    @Entry var authManager: AuthManager = AuthManager()
}

// Inject at app root
struct AppRoot: View {
    @State var authManager = AuthManager()

    var body: some View {
        TabView {
            HomeTab()
            ProfileTab()
        }
        .environment(\.authManager, authManager)
    }
}

// Intermediate views don't know about authManager
struct HomeTab: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
        }
    }
}

struct HomeScreen: View {
    var body: some View {
        FeedView()
    }
}

// Only the view that needs it reads from Environment
struct FeedView: View {
    @Environment(\.authManager) var authManager

    var body: some View {
        if authManager.isLoggedIn {
            Text("Welcome, \(authManager.currentUser?.name ?? "")")
        }
    }
}
```

**Without @Entry macro (pre-Xcode 16):**

```swift
struct AuthManagerKey: EnvironmentKey {
    static let defaultValue = AuthManager()
}

extension EnvironmentValues {
    var authManager: AuthManager {
        get { self[AuthManagerKey.self] }
        set { self[AuthManagerKey.self] = newValue }
    }
}
```

**When NOT to use:** Local state that only affects a single view or its immediate children — use `@State` and pass as properties instead.

Reference: [Apple Documentation — Environment values](https://developer.apple.com/documentation/swiftui/environmentvalues)
