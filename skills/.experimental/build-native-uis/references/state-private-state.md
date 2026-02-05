---
title: "Mark @State Properties as Private"
impact: HIGH
impactDescription: "prevents external mutation, state belongs to the owning view"
tags: state, swiftui, encapsulation, access-control, best-practice
---

## Mark @State Properties as Private

`@State` properties represent a view's internal source of truth. When left non-private, parent views can set initial values through the memberwise initializer, which silently conflicts with SwiftUI's state management and causes the value to be overwritten on every parent re-render.

**Incorrect (non-private @State can be set from outside the view):**

```swift
struct ExpandableSection: View {
    @State var isExpanded = false // accessible in the memberwise initializer

    var body: some View {
        DisclosureGroup("Details", isExpanded: $isExpanded) {
            Text("Additional information about this item.")
        }
    }
}

struct ParentView: View {
    var body: some View {
        ExpandableSection(isExpanded: true) // overwrites state on every re-render
    }
}
```

**Correct (private @State prevents external mutation):**

```swift
struct ExpandableSection: View {
    @State private var isExpanded = false // only this view can mutate it

    var body: some View {
        DisclosureGroup("Details", isExpanded: $isExpanded) {
            Text("Additional information about this item.")
        }
    }
}

struct ParentView: View {
    var body: some View {
        ExpandableSection() // cannot override internal state
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
