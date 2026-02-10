---
title: Provide EditButton for List Management
impact: MEDIUM
impactDescription: enables bulk delete mode and improves accessibility
tags: crud, edit-button, toolbar, accessibility
---

## Provide EditButton for List Management

`EditButton` toggles the list into edit mode, revealing delete indicators for all rows. It provides an accessible alternative to swipe gestures that some users with motor impairments find difficult to perform.

**Incorrect (only swipe-to-delete — poor accessibility):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        NavigationStack {
            List {
                ForEach(friends) { friend in
                    Text(friend.name)
                }
                .onDelete { offsets in
                    for index in offsets { context.delete(friends[index]) }
                }
            }
            // No EditButton — users must discover swipe gesture on their own
        }
    }
}
```

**Correct (EditButton alongside swipe-to-delete):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        NavigationStack {
            List {
                ForEach(friends) { friend in
                    Text(friend.name)
                }
                .onDelete { offsets in
                    for index in offsets { context.delete(friends[index]) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}
```

**Benefits:**
- Accessible to users who cannot perform swipe gestures
- Reveals delete indicators for all rows simultaneously, enabling bulk review
- Standard UIKit/SwiftUI pattern that users recognize

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
