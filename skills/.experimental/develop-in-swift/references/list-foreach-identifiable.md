---
title: Use List and ForEach with Identifiable Data
impact: HIGH
impactDescription: efficient diffing, proper cell reuse, required for dynamic content
tags: list, swiftui, list, foreach, identifiable, collections
---

## Use List and ForEach with Identifiable Data

`List` and `ForEach` require each item to be uniquely identifiable. Conform your model to `Identifiable` protocol or provide an `id` key path. This enables SwiftUI to efficiently update only changed items.

**Incorrect (no identification):**

```swift
// ForEach can't track items without IDs
struct Friend {
    var name: String
}

ForEach(friends) { friend in  // Error: Friend doesn't conform to Identifiable
    Text(friend.name)
}
```

**Correct (Identifiable conformance):**

```swift
// Option 1: Conform to Identifiable
struct Friend: Identifiable {
    let id = UUID()  // Unique identifier
    var name: String
}

List(friends) { friend in
    Text(friend.name)
}

// Option 2: Provide id key path
struct Friend {
    var name: String  // Assuming names are unique
}

List(friends, id: \.name) { friend in
    Text(friend.name)
}

// SwiftData models are automatically Identifiable
@Model
class Friend {  // Already Identifiable via SwiftData
    var name: String
}

// ForEach in custom layouts
VStack {
    ForEach(friends) { friend in
        FriendRow(friend: friend)
    }
}

// With onDelete and onMove
List {
    ForEach(friends) { friend in
        Text(friend.name)
    }
    .onDelete(perform: deleteFriends)
    .onMove(perform: moveFriends)
}
```

**Identifiable rules:**
- Use stable IDs (don't use array index as ID)
- `UUID()` is good for new items
- SwiftData models are automatically Identifiable
- ID must be `Hashable`

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)
