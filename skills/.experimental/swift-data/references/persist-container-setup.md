---
title: Configure ModelContainer at the App Level
impact: CRITICAL
impactDescription: missing container silently prevents all data persistence
tags: persist, model-container, app-setup, swiftdata
---

## Configure ModelContainer at the App Level

The `ModelContainer` must be attached to the top-level `App` or `WindowGroup` using the `.modelContainer(for:)` modifier. Without it, `@Query` returns empty results and `context.insert()` has nowhere to save — the app compiles and runs but silently loses all data.

**Incorrect (no model container — data never persists):**

```swift
import SwiftUI

@main
struct FriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // No .modelContainer — @Query always returns []
            // context.insert() silently fails or crashes
        }
    }
}
```

**Correct (container configured at app level):**

```swift
import SwiftUI
import SwiftData

@main
struct FriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Friend.self)
    }
}
```

**Alternative (multiple model types):**

```swift
@main
struct FriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Friend.self, Event.self, Photo.self])
    }
}
```

**Production caveat:**
`.modelContainer(for:)` crashes the app if the store cannot be created (corrupt file, incompatible schema without migration). For production apps, create the `ModelContainer` manually in the `App.init()` with a do-catch and fallback. See [`persist-container-error-recovery`](persist-container-error-recovery.md) for the full recovery pattern.

**When NOT to use:**
- Unit tests and previews should use in-memory containers instead of the shared app container

Reference: [Develop in Swift — Save Data](https://developer.apple.com/tutorials/develop-in-swift/save-data)
