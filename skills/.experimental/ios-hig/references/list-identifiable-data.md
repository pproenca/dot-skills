---
title: Use List with Identifiable Data
impact: MEDIUM-HIGH
impactDescription: Identifiable enables SwiftUI to track items for efficient diffing and animations
tags: list, identifiable, foreach, diffing, performance
---

## Use List with Identifiable Data

When displaying collections in a List, SwiftUI needs a stable way to identify each element so it can efficiently update only the rows that changed. Using `id: \.self` on plain strings breaks down when duplicates exist and prevents SwiftUI from animating insertions and removals correctly. Conforming your data to `Identifiable` gives each item a stable identity that survives reordering and mutation.

**Incorrect (using id: \.self on plain strings):**

```swift
struct FriendsView: View {
    @State private var friends = ["Alice", "Bob", "Charlie", "Alice"]

    var body: some View {
        List {
            ForEach(friends, id: \.self) { friend in // duplicate "Alice" causes identity conflicts
                Text(friend)
            }
        }
    }
}
```

**Correct (using Identifiable struct with List):**

```swift
struct Friend: Identifiable {
    let id = UUID() // stable identity for each item
    var name: String
}

struct FriendsView: View {
    @State private var friends = [
        Friend(name: "Alice"),
        Friend(name: "Bob"),
        Friend(name: "Charlie"),
        Friend(name: "Alice")
    ]

    var body: some View {
        List(friends) { friend in // List iterates Identifiable data directly
            Text(friend.name)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
