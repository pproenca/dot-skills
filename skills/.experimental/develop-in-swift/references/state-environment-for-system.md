---
title: Use @Environment for System and Shared Values
impact: HIGH
impactDescription: access system settings, inject dependencies, share data without prop drilling
tags: state, swiftui, environment, dependency-injection, system-values
---

## Use @Environment for System and Shared Values

`@Environment` reads values from the SwiftUI environment - both system values (color scheme, dismiss action) and custom values you inject. Use it to access shared dependencies without passing through every view.

**Incorrect (passing through many layers):**

```swift
// Prop drilling - passing dismiss through every view
struct ParentView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ChildView(dismiss: dismiss)
    }
}

struct ChildView: View {
    var dismiss: DismissAction

    var body: some View {
        GrandchildView(dismiss: dismiss)  // Tedious passing
    }
}
```

**Correct (@Environment access where needed):**

```swift
// Access dismiss directly in the view that needs it
struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text("Detail Content")
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Button("Done") {
                dismiss()  // Dismiss the sheet/navigation
            }
        }
    }
}

// Access modelContext for SwiftData operations
struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button("Add Friend") {
            let friend = Friend(name: "New Friend")
            modelContext.insert(friend)
        }
    }
}
```

**Common environment values:**
- `\.dismiss` - Dismiss sheets and navigation
- `\.colorScheme` - Light or dark mode
- `\.modelContext` - SwiftData context
- `\.openURL` - Open URLs
- `\.horizontalSizeClass` - Compact or regular width

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
