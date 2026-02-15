---
title: Handle ModelContainer Creation Failure with Store Recovery
impact: CRITICAL
impactDescription: prevents 100% crash rate on launch when the persistent store is corrupt or incompatible
tags: persist, container, error, recovery, crash, corrupt-store
---

## Handle ModelContainer Creation Failure with Store Recovery

`ModelContainer` creation can fail due to a corrupt store file, an incompatible schema change without a migration plan, or file permission issues. Using `.modelContainer(for:)` in the `App` declaration crashes the app immediately with no recovery path. In production, wrap container creation in a do-catch and provide a fallback — either delete the corrupt store and recreate, or fall back to an in-memory container so the app remains usable.

**Incorrect (.modelContainer crashes on failure — permanent app death):**

```swift
import SwiftUI
import SwiftData

@main
struct TripApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // If the store is corrupt, this crashes on launch with no recovery
        .modelContainer(for: Trip.self)
    }
}
```

**Correct (do-catch with store recovery fallback):**

```swift
import SwiftUI
import SwiftData
import os

@main
struct TripApp: App {
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([Trip.self, Accommodation.self])

        do {
            modelContainer = try ModelContainer(for: schema)
        } catch {
            Logger.persistence.error("Store creation failed: \(error). Attempting recovery.")

            // Attempt recovery: delete the corrupt store and recreate
            let storeURL = URL.applicationSupportDirectory
                .appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)

            do {
                modelContainer = try ModelContainer(for: schema)
                Logger.persistence.info("Store recovery succeeded — data was reset.")
            } catch {
                // Last resort: in-memory container so the app at least launches
                Logger.persistence.critical("Store recovery failed: \(error). Using in-memory store.")
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try! ModelContainer(for: schema, configurations: [config])
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

extension Logger {
    static let persistence = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app", category: "persistence")
}
```

**When NOT to use:**
- Test targets and previews — use in-memory containers directly, no recovery needed
- When data loss is absolutely unacceptable — consider backing up the store file before deletion

**Benefits:**
- App always launches, even with a corrupt store
- Structured logging captures the failure for diagnostics
- In-memory fallback prevents permanent app death while alerting the user
- Recovery path can be extended to attempt backup restoration before deletion

Reference: [Common SwiftData errors and their solutions — Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftdata/common-swiftdata-errors-and-their-solutions)
