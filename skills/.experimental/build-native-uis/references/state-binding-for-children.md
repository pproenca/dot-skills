---
title: "Use @Binding for Two-Way Data Flow to Child Views"
impact: HIGH
impactDescription: "enables child views to read and write parent state without duplication"
tags: state, swiftui, binding, data-flow, parent-child
---

## Use @Binding for Two-Way Data Flow to Child Views

When a child view needs to read and modify a parent's state, passing a plain value creates a one-way copy that silently diverges. `@Binding` establishes a two-way connection so changes in the child propagate back to the source of truth in the parent.

**Incorrect (value copy does not update parent state):**

```swift
struct NotificationToggle: View {
    var isEnabled: Bool // one-way copy, parent never sees changes

    var body: some View {
        Toggle("Notifications", isOn: .constant(isEnabled))
    }
}

struct SettingsScreen: View {
    @State private var isEnabled = false

    var body: some View {
        Form {
            NotificationToggle(isEnabled: isEnabled) // passes a snapshot
        }
    }
}
```

**Correct (@Binding creates a two-way connection to parent state):**

```swift
struct NotificationToggle: View {
    @Binding var isEnabled: Bool // reads and writes the parent's state

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}

struct SettingsScreen: View {
    @State private var isEnabled = false

    var body: some View {
        Form {
            NotificationToggle(isEnabled: $isEnabled) // passes a binding
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
