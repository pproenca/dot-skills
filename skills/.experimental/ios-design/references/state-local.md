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

**When NOT to use @State:**
- For reference types (classes) - use @State with @Observable instead
- For data that needs to be shared with parent views - use @Binding
- For app-wide data - use @Environment

**Note:** Always mark @State properties as `private` since they should only be modified by the owning view.

Reference: [State Management in SwiftUI](https://developers-heaven.net/blog/state-management-in-swiftui-state-binding-observable-and-environment/)
