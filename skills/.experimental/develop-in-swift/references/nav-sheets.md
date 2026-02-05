---
title: Use Sheets for Modal Presentation
impact: HIGH
impactDescription: temporary focused tasks, maintains context, proper dismiss handling
tags: nav, swiftui, navigation, sheets, modal, presentation
---

## Use Sheets for Modal Presentation

Sheets present content modally over the current view. Use `.sheet()` modifier with a binding to control presentation. Sheets are ideal for focused tasks like adding new items or editing details.

**Incorrect (manual overlay implementation):**

```swift
// Don't build custom modal overlays
struct ContentView: View {
    @State private var showingAdd = false

    var body: some View {
        ZStack {
            MainContent()
            if showingAdd {
                Color.black.opacity(0.3)
                AddItemView()
            }
        }
    }
}
```

**Correct (sheet with boolean binding):**

```swift
struct FriendListView: View {
    @State private var showingAddFriend = false

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                showingAddFriend = true
            }
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView()
        }
    }
}

// Sheet with item binding (auto-unwraps optional)
struct FriendListView: View {
    @State private var selectedFriend: Friend?

    var body: some View {
        List(friends) { friend in
            Button(friend.name) {
                selectedFriend = friend
            }
        }
        .sheet(item: $selectedFriend) { friend in
            FriendDetailView(friend: friend)
        }
    }
}

// Dismissing from within sheet
struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Form content
            }
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
```

**Sheet patterns:**
- `isPresented:` for boolean toggle
- `item:` for optional binding (nil = hidden)
- Access `\.dismiss` environment action
- Wrap sheet content in NavigationStack for toolbar

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
