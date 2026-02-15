---
title: Inject Dependencies via @Environment With Custom EnvironmentKey
impact: MEDIUM-HIGH
impactDescription: eliminates init parameter drilling, enables testing without view changes
tags: di, environment, environment-key, injection, entry-macro
---

## Inject Dependencies via @Environment With Custom EnvironmentKey

SwiftUI's `@Environment` is the native dependency injection mechanism. Define custom `EnvironmentKey` types for services (repositories, use cases, coordinators) and inject them at the app root. Views read dependencies with `@Environment(\.userRepository)` — no constructor parameter needed. Use the `@Entry` macro (Xcode 16+) to eliminate the boilerplate of defining a key and extension separately.

**Incorrect (passing repository through 4 levels of view init parameters):**

```swift
// Repository drilled through every intermediate view
struct AppRootView: View {
    let userRepository: UserRepository

    var body: some View {
        TabView {
            // Level 1: pass down
            HomeTab(userRepository: userRepository)
        }
    }
}

struct HomeTab: View {
    let userRepository: UserRepository  // doesn't use it, just passes it

    var body: some View {
        NavigationStack {
            // Level 2: pass down again
            HomeScreen(userRepository: userRepository)
        }
    }
}

struct HomeScreen: View {
    let userRepository: UserRepository  // still doesn't use it

    var body: some View {
        // Level 3: pass down yet again
        ProfileSummary(userRepository: userRepository)
    }
}

struct ProfileSummary: View {
    let userRepository: UserRepository  // finally uses it

    var body: some View {
        Text(userRepository.currentUser?.name ?? "Guest")
    }
}
```

**Correct (@Entry macro shorthand — Xcode 16+, minimal boilerplate):**

```swift
// @Entry macro generates EnvironmentKey + extension in one declaration
extension EnvironmentValues {
    @Entry var userRepository: any UserRepositoryProtocol = LiveUserRepository()
}

// App root injects the live implementation once
@main
struct MyApp: App {
    let userRepository: any UserRepositoryProtocol = LiveUserRepository()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.userRepository, userRepository)
        }
    }
}

// Any view at ANY depth reads the dependency directly — no drilling
struct ProfileSummary: View {
    @Environment(\.userRepository) var userRepository

    var body: some View {
        Text(userRepository.currentUser?.name ?? "Guest")
    }
}
```

**Correct (traditional EnvironmentKey definition — pre-Xcode 16 or explicit control):**

```swift
// Step 1: Define the EnvironmentKey with a default value
private struct UserRepositoryKey: EnvironmentKey {
    static let defaultValue: any UserRepositoryProtocol = LiveUserRepository()
}

// Step 2: Extend EnvironmentValues with a computed property
extension EnvironmentValues {
    var userRepository: any UserRepositoryProtocol {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }
}

// Usage is identical to the @Entry version
struct ProfileSummary: View {
    @Environment(\.userRepository) var userRepository

    var body: some View {
        Text(userRepository.currentUser?.name ?? "Guest")
    }
}
```

**Key benefits:**
- No parameter drilling — intermediate views are completely unaware of dependencies they don't use
- Testing: inject mocks via `.environment(\.userRepository, MockUserRepository())` in previews and tests
- `@Entry` macro reduces the traditional 3-step EnvironmentKey pattern to a single line

Reference: [Apple Documentation — Environment values](https://developer.apple.com/documentation/swiftui/environmentvalues)
