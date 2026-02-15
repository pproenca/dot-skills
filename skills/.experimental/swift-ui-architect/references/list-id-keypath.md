---
title: Provide Explicit id KeyPath — Never Rely on Implicit Identity
impact: MEDIUM
impactDescription: prevents O(N) view recreation and @State loss from hash collisions
tags: list, identity, keypath, foreach, identifiable
---

## Provide Explicit id KeyPath — Never Rely on Implicit Identity

Always make models conform to `Identifiable` with a stable `id` property, or provide an explicit `id:` keyPath to `ForEach`. Never use `\.self` for non-trivial types (it uses the hash, which can collide) and never use array indices (which change on insert/delete). Stable identifiers ensure SwiftUI correctly tracks view state and animations across updates.

**Incorrect (\.self identity — hash collisions cause state corruption):**

```swift
struct TagListView: View {
    let tags: [Tag]

    var body: some View {
        // \.self uses Hashable — if two Tags hash identically,
        // SwiftUI treats them as the same view
        ForEach(tags, id: \.self) { tag in
            TagChip(tag: tag)
        }
    }
}

// \.self on String — duplicate strings are treated as the same view
ForEach(["Draft", "Review", "Draft"], id: \.self) { status in
    // The two "Draft" entries are considered the SAME identity
    // One will be silently dropped or share state with the other
    StatusBadge(status: status)
}
```

**Incorrect (array index identity — state follows wrong items on insert/delete):**

```swift
struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            // Index-based identity: item at index 0 is always "identity 0"
            ForEach(0..<viewModel.tasks.count, id: \.self) { index in
                TaskRow(task: viewModel.tasks[index])
            }
        }
    }
}

// Problem: user deletes item at index 2
// Before: [A(0), B(1), C(2), D(3)]
// After:  [A(0), B(1), D(2)]
// SwiftUI thinks identity "2" is the same view — it shows C's state with D's data
// Animations: SwiftUI animates the LAST item as removed, not the deleted one
```

**Correct (Identifiable with stable database ID):**

```swift
struct Task: Identifiable {
    let id: UUID            // stable — survives insert, delete, reorder
    var title: String
    var isComplete: Bool
}

struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            // Identifiable — ForEach uses the stable UUID automatically
            ForEach(viewModel.tasks) { task in
                TaskRow(task: task)
            }
            // Insert at index 0: [New, A, B, C, D]
            // SwiftUI correctly identifies New as a NEW view
            // A, B, C, D retain their state and animate to new positions
        }
    }
}
```

**Correct (explicit id keyPath when Identifiable isn't appropriate):**

```swift
struct ServerLog: Codable {
    let timestamp: Date
    let message: String
    let traceId: String     // stable unique identifier from server
}

struct LogListView: View {
    let logs: [ServerLog]

    var body: some View {
        List {
            // Explicit keyPath when the type doesn't conform to Identifiable
            ForEach(logs, id: \.traceId) { log in
                LogRow(log: log)
            }
        }
    }
}
```

**Identity stability rules:**
- Use database/server IDs (UUID, Int primary key) — they survive reordering and filtering
- Use `UUID()` generated at creation time — not at render time (that creates new identity every render)
- Avoid computed identities that change when data changes (e.g., `id: \.title` breaks if title is edited)

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
