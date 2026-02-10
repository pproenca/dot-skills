---
title: Use @State for View-Local Value Types
impact: CRITICAL
impactDescription: prevents memory leaks and unexpected re-initialization
tags: state, state-wrapper, value-types, view-lifecycle
---

## Use @State for View-Local Value Types

@State is for value types (structs, enums, primitives) that belong exclusively to a view. SwiftUI manages the storage and persists it across view updates.

**Incorrect (local variable resets on every body call):**

```swift
struct CounterView: View {
    var count = 0  // Resets to 0 on every re-render

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1  // Compiler error: cannot mutate
            }
        }
    }
}
```

**Correct (state persists across re-renders):**

```swift
struct CounterView: View {
    @State private var count = 0  // Persisted by SwiftUI

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1  // Triggers re-render with new value
            }
        }
    }
}
```

**Always mark @State as private** — when left non-private, parent views can set values through the memberwise initializer, silently overwriting state on every re-render:

```swift
// Wrong: non-private @State exposed in initializer
struct Section: View {
    @State var isExpanded = false
}
Section(isExpanded: true) // overwrites on every parent re-render

// Right: private prevents external mutation
struct Section: View {
    @State private var isExpanded = false
}
```

**When NOT to use @State:**
- For reference types (classes) — use @State with @Observable instead
- For data shared with parent views — use @Binding
- For app-wide data — use @Environment

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
