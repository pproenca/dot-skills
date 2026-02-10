---
title: Create a SampleData Singleton for Previews
impact: MEDIUM
impactDescription: centralizes preview data, prevents duplication across preview providers
tags: preview, sample-data, singleton, development
---

## Create a SampleData Singleton for Previews

A single `SampleData` class shared across all previews ensures consistency and avoids duplicate setup code. Use `static let shared` with a private init to guarantee a single instance that every preview provider references.

**Incorrect (each preview creates its own container — duplicated code, inconsistent data):**

```swift
#Preview {
    let schema = Schema([Friend.self, Movie.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext
    context.insert(Friend(name: "Elena", birthday: .now))
    context.insert(Friend(name: "Graham", birthday: .now))
    return ContentView()
        .modelContainer(container)
}

// Another file repeats the exact same setup with slightly different data
#Preview {
    let schema = Schema([Friend.self, Movie.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext
    context.insert(Friend(name: "Elena", birthday: .now))
    return FriendDetailView(friend: Friend(name: "Elena", birthday: .now))
        .modelContainer(container)
}
```

**Correct (singleton shared across all previews):**

```swift
@MainActor
class SampleData {
    static let shared = SampleData()
    let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        let schema = Schema([Friend.self, Movie.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            insertSampleData()
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    private func insertSampleData() {
        for friend in Friend.sampleData {
            context.insert(friend)
        }
        try? context.save()
    }
}

// Every preview uses the same shared instance
#Preview {
    ContentView()
        .modelContainer(SampleData.shared.modelContainer)
}
```

**Benefits:**
- One source of truth for all preview data
- Changes to sample data propagate to every preview automatically
- No risk of inconsistent data between preview providers

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
