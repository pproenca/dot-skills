---
title: Configure modelContainer in App Entry Point
impact: HIGH
impactDescription: enables SwiftData persistence, provides context to all views, required setup
tags: data, swiftdata, modelcontainer, app, configuration
---

## Configure modelContainer in App Entry Point

Add the `.modelContainer(for:)` modifier to your app's main scene to enable SwiftData. This creates the database and makes the model context available throughout your view hierarchy.

**Incorrect (no container setup):**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // @Query will fail without modelContainer!
        }
    }
}
```

**Correct (modelContainer configured):**

```swift
import SwiftUI
import SwiftData

@main
struct FriendsFavoritesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Friend.self, Movie.self])
    }
}

// For previews, create a sample data container
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(SampleData.shared.modelContainer)
    }
}

// Sample data helper for previews
@MainActor
class SampleData {
    static let shared = SampleData()

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Friend.self, Movie.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: config)

        // Insert sample data
        let context = modelContainer.mainContext
        context.insert(Friend(name: "Sophie"))
        context.insert(Friend(name: "Alex"))
    }
}
```

**Container options:**
- `isStoredInMemoryOnly: true` - For previews and testing
- Multiple model types in single container
- CloudKit sync configuration
- Custom storage location

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
