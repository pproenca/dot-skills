---
title: Customize Storage with ModelConfiguration
impact: LOW-MEDIUM
impactDescription: enables extension data sharing and explicit control over store location
tags: schema, configuration, storage, model-container
---

## Customize Storage with ModelConfiguration

`ModelConfiguration` lets you customize storage location, read-only mode, and App Group sharing. The default configuration works for most single-app cases, but widget extensions, shared data between targets, and testing scenarios require explicit configuration.

**Incorrect (default configuration for widget extension — widget can't access app's data):**

```swift
// Main app stores data in its default container
@main
struct FriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Friend.self)
        // Data stored in app's private container
    }
}

// Widget tries to read the same data — different sandbox, empty results
struct FriendsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "friends", provider: Provider()) { entry in
            WidgetView(entry: entry)
                .modelContainer(for: Friend.self)
            // Different container — can't see main app's data
        }
    }
}
```

**Correct (custom URL for your app only):**

```swift
import SwiftData

let schema = Schema([Friend.self, Movie.self])
let fileURL = URL.applicationSupportDirectory.appending(path: "friends.store")

// This is still app-sandbox storage (not shared with extensions).
let configuration = ModelConfiguration(schema: schema, url: fileURL)
let container = try ModelContainer(for: schema, configurations: configuration)
```

**Correct (shared App Group storage for app + extensions):**

```swift
import SwiftData

let schema = Schema([Friend.self, Movie.self])
let configuration = ModelConfiguration(
    groupContainer: .identifier("group.com.example.myapp")
)
let container = try ModelContainer(for: schema, configurations: configuration)
```

**Alternative (in-memory configuration for tests and previews):**

```swift
let schema = Schema([Friend.self, Movie.self])
let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: schema, configurations: [configuration])
```

**When NOT to use:**
- Single-app projects with no extensions or shared data — the default configuration is simpler and sufficient
- Read-only bundled databases should use `allowsSave: false` to prevent accidental writes

**Benefits:**
- App Groups enable data sharing between the main app, widgets, and extensions
- Explicit URL control prevents data from scattering across default locations
- In-memory mode eliminates disk I/O for tests and previews

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)
