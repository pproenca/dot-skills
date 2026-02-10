---
title: "Use Spacer to Push Views Apart"
impact: CRITICAL
impactDescription: "distributes flexible space; prevents hardcoded spacing that breaks across devices"
tags: layout, spacer, distribution, toolbar, flexible
---

## Use Spacer to Push Views Apart

Hardcoded padding or offset values to push views apart are fragile -- they break across screen sizes and orientations. Spacer is a flexible view that expands to fill all available space along the stack's axis, automatically distributing content to edges or between elements. This produces layouts that stay correct regardless of device dimensions.

**Incorrect (hardcoded padding breaks on different screen widths):**

```swift
struct ToolbarView: View {
    let documentTitle: String

    var body: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "chevron.left")
            }
            Text(documentTitle)
                .font(.headline)
                .padding(.leading, 90) // fragile: only looks centered on one screen width
            Button(action: { }) {
                Image(systemName: "square.and.arrow.up")
            }
            .padding(.leading, 80)
        }
        .padding()
    }
}
```

**Correct (Spacer fills available space to distribute views):**

```swift
struct ToolbarView: View {
    let documentTitle: String

    var body: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "chevron.left")
            }
            Spacer() // pushes title to center
            Text(documentTitle)
                .font(.headline)
            Spacer() // pushes action button to trailing edge
            Button(action: { }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
