---
title: Use Stable O(1) Identifiers in ForEach
impact: HIGH
impactDescription: prevents full list rebuilds — SwiftUI tracks insertions/deletions via stable IDs
tags: diff, identity, foreach, identifiable, performance
---

## Use Stable O(1) Identifiers in ForEach

SwiftUI uses view identity to track which items were added, removed, or moved in a list. If identifiers are unstable (array index, computed hash, or `\.self` on non-unique values), SwiftUI cannot correlate items across updates and tears down/rebuilds the entire list. Use stable, unique, O(1) identifiers — typically a UUID or database primary key.

**Incorrect (array index as identity — full rebuild on any mutation):**

```swift
struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            ForEach(Array(viewModel.tasks.enumerated()), id: \.offset) { index, task in
                // Index-based identity: inserting at position 0
                // shifts ALL indices, causing full list rebuild
                TaskRow(task: task)
            }
        }
    }
}
```

**Also incorrect (\.self on non-unique strings — collisions cause missing rows):**

```swift
struct TagListView: View {
    let tags: [String]

    var body: some View {
        ForEach(tags, id: \.self) { tag in
            // Duplicate strings have same identity — SwiftUI drops duplicates
            // "swift" appearing twice renders only once
            TagChip(text: tag)
        }
    }
}
```

**Correct (stable Identifiable conformance — O(1) lookup, correct diffing):**

```swift
struct TaskItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                // UUID identity persists across mutations
                // Inserting/removing items only affects changed rows
                TaskRow(task: task)
            }
        }
    }
}

struct Tag: Identifiable, Equatable {
    let id: UUID
    let text: String
}

struct TagListView: View {
    let tags: [Tag]

    var body: some View {
        ForEach(tags) { tag in
            // Each tag has unique identity — no collisions
            TagChip(text: tag.text)
        }
    }
}
```

Reference: [Demystify SwiftUI — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10022/)
