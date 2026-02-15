---
title: Use Stable O(1) Identifiers in ForEach
impact: HIGH
impactDescription: prevents O(N) full-list rebuild on every update, preserves @State across renders
tags: diff, identity, foreach, identifiable, list
---

## Use Stable O(1) Identifiers in ForEach

SwiftUI uses identifiers to track view lifecycle across updates. If identifiers change between renders (e.g., using array index or `UUID()`), SwiftUI destroys and recreates views instead of updating them, losing `@State` and animation context. Use stable, model-derived identifiers.

**Incorrect (array index as id — state loss and full rebuild on reorder):**

```swift
struct MessageList: View {
    let messages: [Message]

    var body: some View {
        List {
            // Array index changes when items are inserted/deleted/reordered
            // SwiftUI destroys and recreates ALL views below the change point
            ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                MessageRow(message: message)
            }
        }
    }
}
```

**Incorrect (UUID() generated inline — every render creates new identities):**

```swift
struct MessageList: View {
    let messages: [Message]

    var body: some View {
        List {
            // UUID() creates a NEW identity on every body evaluation
            // Every view is destroyed and recreated every time
            ForEach(messages, id: \.self.hashValue) { message in
                MessageRow(message: message)
            }
        }
    }
}
```

**Correct (stable model-derived ID via Identifiable):**

```swift
struct Message: Identifiable {
    let id: String  // stable database/server ID — never changes for same item
    let content: String
    let timestamp: Date
}

struct MessageList: View {
    let messages: [Message]

    var body: some View {
        List {
            // Stable ID — SwiftUI tracks each view across updates
            // Insertions/deletions animate correctly, @State is preserved
            ForEach(messages) { message in
                MessageRow(message: message)
            }
        }
    }
}
```

**When NOT to use:** If items genuinely have no stable identity (e.g., random decorative elements), `UUID` stored as a property (not generated inline) is acceptable.

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
