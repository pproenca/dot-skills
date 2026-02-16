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
@Equatable
struct FriendList: View {
    @State private var viewModel: FriendListViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.friends) { friend in
                    Text(friend.name)
                }
                .onDelete { offsets in
                    Task { await viewModel.deleteFriends(at: offsets) }
                }
            }
            // No EditButton — users must discover swipe gesture on their own
        }
    }
}
```

**Correct (EditButton alongside swipe-to-delete):**

```swift
@Equatable
struct FriendList: View {
    @State private var viewModel: FriendListViewModel

    init(friendRepository: FriendRepository) {
        _viewModel = State(initialValue: FriendListViewModel(friendRepository: friendRepository))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.friends) { friend in
                    Text(friend.name)
                }
                .onDelete { offsets in
                    Task { await viewModel.deleteFriends(at: offsets) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .task { await viewModel.loadFriends() }
    }
}
```

**Benefits:**
- Accessible to users who cannot perform swipe gestures
- Reveals delete indicators for all rows simultaneously, enabling bulk review
- Standard UIKit/SwiftUI pattern that users recognize

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
