---
title: Use App Groups for Shared Data Storage
impact: LOW-MEDIUM
impactDescription: enables data sharing between app and extensions (widgets, watch)
tags: persist, app-group, extensions, configuration
---

## Use App Groups for Shared Data Storage

By default, SwiftData stores data in the app's sandbox, inaccessible to extensions. To share data between your main app and its extensions (widgets, watch complications, share extensions), configure the `ModelContainer` with an App Group identifier.

**Incorrect (default configuration — widget can't access data):**

```swift
// Main App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
        // Data stored in app sandbox — widget has its own empty sandbox
    }
}

// Widget — has no access to the app's database
struct TripWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "trip", provider: TripProvider()) { entry in
            TripWidgetView(entry: entry)
        }
        .modelContainer(for: Trip.self)
        // Creates a SEPARATE empty database in the widget's sandbox
    }
}
```

**Correct (shared App Group container):**

```swift
// Shared configuration used by both app and widget
extension ModelContainer {
    static let shared: ModelContainer = {
        let config = ModelConfiguration(
            groupContainer: .identifier("group.com.example.myapp")
        )
        return try! ModelContainer(for: Trip.self, configurations: config)
    }()
}

// Main App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainer.shared)
    }
}

// Widget — reads the same database
struct TripWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "trip", provider: TripProvider()) { entry in
            TripWidgetView(entry: entry)
                .modelContainer(ModelContainer.shared)
        }
    }
}
```

**When NOT to use:**
- Apps without extensions do not need App Groups
- If extensions only need a small subset of data, consider passing it via UserDefaults(suiteName:) instead

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
