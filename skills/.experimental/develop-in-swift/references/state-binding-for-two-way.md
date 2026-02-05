---
title: Use @Binding for Two-Way Data Flow
impact: CRITICAL
impactDescription: child views can modify parent state, enables reusable input components
tags: state, swiftui, binding, data-flow, two-way, child-views
---

## Use @Binding for Two-Way Data Flow

`@Binding` creates a two-way connection to state owned by another view. The child view can read and write the value, and changes propagate back to the parent. Use `$` prefix to pass a binding from `@State`.

**Incorrect (one-way data only):**

```swift
// Child can't modify parent's state
struct ToggleRow: View {
    var isOn: Bool  // Read-only copy

    var body: some View {
        Toggle("Setting", isOn: isOn)  // Error: needs Binding<Bool>
    }
}
```

**Correct (@Binding for two-way connection):**

```swift
struct ToggleRow: View {
    @Binding var isOn: Bool  // Two-way connection

    var body: some View {
        Toggle("Setting", isOn: $isOn)  // Pass binding to Toggle
    }
}

// Parent view
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var soundEnabled = false

    var body: some View {
        VStack {
            // Pass binding with $ prefix
            ToggleRow(isOn: $notificationsEnabled)
            ToggleRow(isOn: $soundEnabled)
        }
    }
}

// TextField requires binding for text
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)  // $ creates binding
    }
}
```

**Binding patterns:**
- Create from @State with `$` prefix: `$myState`
- Accept in child view with `@Binding var`
- Built-in controls (Toggle, TextField, Slider) require bindings
- Don't use @Binding when child only reads data

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)
