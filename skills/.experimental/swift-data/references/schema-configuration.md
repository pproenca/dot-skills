---
title: Customize Storage with ModelConfiguration
impact: LOW-MEDIUM
impactDescription: enables 100% of extension data sharing use cases
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

**Correct (shared configuration with explicit URL and App Group):**

```swift
let schema = Schema([Friend.self, Movie.self])
let configuration = ModelConfiguration(
    schema: schema,
    url: URL.applicationSupportDirectory.appending(path: "friends.store"),
    allowsSave: true
)
let container = try ModelContainer(for: schema, configurations: [configuration])
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

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
