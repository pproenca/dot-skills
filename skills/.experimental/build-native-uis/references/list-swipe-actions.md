---
title: Add Swipe Actions for Contextual Operations
impact: MEDIUM-HIGH
impactDescription: standard iOS pattern for delete, archive, and other row-level actions
tags: list, swipe-actions, gestures, contextual-menu, delete
---

## Add Swipe Actions for Contextual Operations

Swipe actions are the standard iOS pattern for row-level operations like delete, archive, and favorite. Embedding dedicated buttons directly inside each row clutters the visible layout and deviates from platform conventions users already know. The `.swipeActions` modifier keeps the row clean while making destructive and common actions discoverable through the familiar swipe gesture.

**Incorrect (dedicated delete button visible in each row):**

```swift
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                HStack {
                    Text(message)
                    Spacer()
                    Button("Delete") { // clutters every row with a visible button
                        messages.removeAll { $0 == message }
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}
```

**Correct (using .swipeActions for delete and favorite):**

```swift
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]
    @State private var favorites: Set<String> = []

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                Text(message)
                    .swipeActions(edge: .trailing) { // standard destructive action on trailing edge
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

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
