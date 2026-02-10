---
title: Use In-Memory Configuration for Tests and Previews
impact: MEDIUM
impactDescription: prevents test pollution and preview data duplication
tags: persist, in-memory, testing, previews, configuration
---

## Use In-Memory Configuration for Tests and Previews

Tests and previews that use persistent (on-disk) storage accumulate duplicate data across runs and leak state between test cases. Use `ModelConfiguration(isStoredInMemoryOnly: true)` to get a clean database every time — no leftover data, no test ordering issues, no preview pollution.

**Incorrect (previews using default persistent container):**

```swift
#Preview {
    ContentView()
        .modelContainer(for: Friend.self)
    // Each preview refresh adds duplicate sample data to disk
    // Preview data persists across Xcode restarts
}
```

**Correct (in-memory container for previews):**

```swift
struct SampleData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Friend.self, configurations: config)

        let context = container.mainContext
        context.insert(Friend(name: "Alex", birthday: .now))
        context.insert(Friend(name: "Jordan", birthday: .now))

        return container
    }()
}

#Preview {
    ContentView()
        .modelContainer(SampleData.container)
    // Fresh sample data every time — no duplicates
}
```

**Alternative (in-memory container for unit tests):**

```swift
@Test func addFriend() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Friend.self, configurations: config)
    let context = ModelContext(container)

    let friend = Friend(name: "Alex", birthday: .now)
    context.insert(friend)
    try context.save()

    let friends = try context.fetch(FetchDescriptor<Friend>())
    #expect(friends.count == 1)
    // Database is discarded when test ends — no cleanup needed
}
```

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
