---
title: Use @State for View-Local Value Types
impact: CRITICAL
impactDescription: prevents 100% of state-reset-on-re-render bugs — without @State, values revert to their initial value 60-120× per second during animations, causing complete loss of user input and interaction state
tags: craft, state, value-types, kocienda-craft, view-lifecycle
---

## Use @State for View-Local Value Types

Kocienda defines craft as applying skill to achieve a high-quality result. The difference between `var count = 0` and `@State private var count = 0` is invisible in a screenshot but catastrophic in use — the first resets to zero every time SwiftUI re-evaluates the body, the second persists across re-renders. Craftsmanship means understanding the runtime behavior beneath the declaration syntax. A craftsman doesn't leave state management to chance; they choose the right wrapper for each situation with the precision of a watchmaker selecting a spring.

**Incorrect (local variable resets on every body call):**

```swift
struct FavoriteButton: View {
    var isFavorited = false  // Resets to false on every re-render

    var body: some View {
        Button {
            isFavorited.toggle()  // Compiler error: cannot mutate
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
        }
    }
}
```

**Correct (state persists across re-renders):**

```swift
struct FavoriteButton: View {
    @State private var isFavorited = false

    var body: some View {
        Button {
            isFavorited.toggle()  // Triggers re-render with new value
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .foregroundStyle(isFavorited ? .red : .secondary)
        }
    }
}
```

**Always mark @State as private** — when left non-private, parent views can set values through the memberwise initializer, silently overwriting state on every re-render:

```swift
// Wrong: parent overwrites state on every re-render
struct ExpandableSection: View {
    @State var isExpanded = false
}
ExpandableSection(isExpanded: true) // resets every parent update

// Right: private prevents external mutation
struct ExpandableSection: View {
    @State private var isExpanded = false
}
```

**When NOT to use @State:**
- For reference types (classes) — use `@State` with `@Observable` instead
- For data shared with parent views — use `@Binding`
- For app-wide data — use `@Environment`
- For data that outlives the view — use a model layer

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
