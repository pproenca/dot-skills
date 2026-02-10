---
title: Use Sheets for Focused Data Creation
impact: MEDIUM
impactDescription: prevents accidental navigation away from incomplete data entry
tags: crud, sheet, modal, creation, ux
---

## Use Sheets for Focused Data Creation

Present new item creation in a sheet rather than pushing a navigation view. Sheets keep users focused on the creation task and provide a clear Save/Cancel flow. Combined with `.interactiveDismissDisabled()`, they prevent accidental dismissal of partially entered data.

**Incorrect (navigation push for creation — easy to lose data):**

```swift
struct FriendList: View {
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        NavigationStack {
            List(friends) { friend in
                Text(friend.name)
            }
            .toolbar {
                // User can swipe back mid-entry and lose partially entered data
                NavigationLink("Add Friend") {
                    FriendDetailView(friend: Friend(name: ""))
                }
            }
        }
    }
}
```

**Correct (sheet with dismiss protection):**

```swift
struct FriendList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var newFriend: Friend?

    var body: some View {
        NavigationStack {
            List(friends) { friend in
                Text(friend.name)
            }
            .toolbar {
                Button("Add Friend") {
                    let friend = Friend(name: "")
                    context.insert(friend)
                    newFriend = friend
                }
            }
            .sheet(item: $newFriend) { friend in
                NavigationStack {
                    FriendDetailView(friend: friend, isNew: true)
                }
                .interactiveDismissDisabled()
            }
        }
    }
}
```

**Important:** This pattern inserts the model before the sheet appears. With autosave enabled, an empty record may persist if the app is killed before the user cancels. Always pair this with a cancel handler that deletes the unsaved model — see [`crud-cancel-delete`](crud-cancel-delete.md).

**Benefits:**
- Clear modal context signals "you are creating something new"
- `.interactiveDismissDisabled()` prevents accidental swipe-to-dismiss
- Save/Cancel buttons provide explicit intent

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
