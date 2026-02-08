---
title: Use Environment Keys for Service Injection
impact: MEDIUM
impactDescription: eliminates singleton access, enables per-preview configuration
tags: arch, environment, dependency-injection, testability, singleton
---

## Use Environment Keys for Service Injection

Singletons like `DatabaseManager.shared` create hidden coupling -- every view that uses one silently depends on global mutable state that cannot be swapped for testing or previews. SwiftUI's `EnvironmentKey` mechanism makes the dependency explicit and scoped to the view hierarchy: you can inject a real service at the app root and a mock at the preview root without changing the view code. This also prevents the "singleton knows too much" problem where unrelated views share and mutate the same global instance.

**Incorrect (singleton creates hidden coupling, untestable):**

```swift
class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    func fetchNotes() async -> [Note] {
        // Real database query
    }
}

struct NoteListView: View {
    @State private var notes: [Note] = []

    var body: some View {
        List(notes) { note in
            Text(note.title)
        }
        .task {
            notes = await DatabaseManager.shared.fetchNotes()
        }
    }
}
```

**Correct (environment key makes dependency explicit and swappable):**

```swift
protocol NoteStore {
    func fetchNotes() async -> [Note]
}

class DatabaseManager: NoteStore {
    func fetchNotes() async -> [Note] {
        // Real database query
    }
}

struct MockNoteStore: NoteStore {
    func fetchNotes() async -> [Note] {
        [Note(id: "1", title: "Sample Note")]
    }
}

private struct NoteStoreKey: EnvironmentKey {
    static let defaultValue: NoteStore = DatabaseManager()
}

extension EnvironmentValues {
    var noteStore: NoteStore {
        get { self[NoteStoreKey.self] }
        set { self[NoteStoreKey.self] = newValue }
    }
}

struct NoteListView: View {
    @Environment(\.noteStore) private var store
    @State private var notes: [Note] = []

    var body: some View {
        List(notes) { note in
            Text(note.title)
        }
        .task {
            notes = await store.fetchNotes()
        }
    }
}

#Preview {
    NoteListView()
        .environment(\.noteStore, MockNoteStore())
}
```

Reference: [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey)
