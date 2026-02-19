---
title: Add Swipe Actions for Contextual Operations
impact: MEDIUM-HIGH
impactDescription: 1 gesture vs 2-3 taps — swipe actions complete row operations 60% faster than visible buttons
tags: inter, list, swipe-actions, gestures, contextual-menu, delete
---

## Add Swipe Actions for Contextual Operations

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Swipe actions are the standard iOS pattern for row-level operations like delete, archive, and favorite. Embedding dedicated buttons directly inside each row clutters the visible layout and deviates from platform conventions users already know. The `.swipeActions` modifier keeps the row clean while making destructive and common actions discoverable through the familiar swipe gesture.

**Incorrect (custom swipe gesture or visible buttons):**

```swift
// Don't implement custom swipe gestures for standard actions
List(friends) { friend in
    Text(friend.name)
        .gesture(DragGesture()...)  // Complex and non-standard
}

// Dedicated delete button visible in each row clutters the layout
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                HStack {
                    Text(message)
                    Spacer()
                    Button("Delete") {
                        messages.removeAll { $0 == message }
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}
```

**Correct (using .swipeActions and .onDelete):**

```swift
// Simple delete with onDelete
struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete(perform: deleteFriends)
        }
    }

    private func deleteFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
    }
}

// Custom swipe actions with leading and trailing edges
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]
    @State private var favorites: Set<String> = []

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                Text(message)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            messages.removeAll { $0 == message }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            favorites.insert(message)
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
            }
        }
    }
}
```

**Swipe action patterns:**
- `.onDelete()` enables Edit mode and swipe-to-delete
- `.swipeActions(edge:)` for custom actions
- Use `role: .destructive` for delete actions
- Leading edge for positive actions, trailing for destructive

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
