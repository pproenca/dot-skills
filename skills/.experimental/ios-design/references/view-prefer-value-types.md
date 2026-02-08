---
title: Prefer Value Types for View Data
impact: HIGH
impactDescription: enables automatic diffing and prevents reference-related bugs
tags: view, value-types, struct, diffing, data
---

## Prefer Value Types for View Data

Pass structs and enums to views, not classes. SwiftUI's diffing works best with value types, and you avoid reference-related state bugs.

**Incorrect (passing class instances):**

```swift
class TodoItem {  // Reference type
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct TodoRow: View {
    let item: TodoItem  // Reference - mutations don't trigger updates

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            Text(item.title)
        }
    }
}
```

**Correct (value types):**

```swift
struct TodoItem: Identifiable {  // Value type
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct TodoRow: View {
    let item: TodoItem  // Value - SwiftUI detects changes

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            Text(item.title)
        }
    }
}
```

**When you need reference semantics, use @Observable:**

```swift
@Observable
class AppState {  // Shared mutable state
    var currentUser: User?
    var settings: Settings = .default
}

struct SettingsView: View {
    @Bindable var appState: AppState  // @Bindable for @Observable classes

    var body: some View {
        Toggle("Dark Mode", isOn: $appState.settings.darkModeEnabled)
    }
}
```

**Model design pattern:**

```swift
// Domain models as value types
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
}

// App state as @Observable class
@Observable
class UserStore {
    var users: [User] = []
    var selectedUserID: UUID?

    var selectedUser: User? {
        users.first { $0.id == selectedUserID }
    }
}
```

Reference: [SwiftUI Data Flow](https://matteomanferdini.com/swiftui-data-flow/)
