---
title: Use @Binding for Child View Mutations
impact: CRITICAL
impactDescription: enables two-way data flow without duplicating state
tags: state, binding, child-views, data-flow
---

## Use @Binding for Child View Mutations

@Binding creates a two-way connection to state owned by a parent view. The child can read and write the value, but the parent remains the source of truth.

**Incorrect (duplicating state in child):**

```swift
struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        // Child has its own copy, parent never sees changes
        NotificationToggle(isEnabled: notificationsEnabled)
    }
}

struct NotificationToggle: View {
    @State var isEnabled: Bool  // Separate state, not connected

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}
```

**Correct (binding to parent's state):**

```swift
struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        NotificationToggle(isEnabled: $notificationsEnabled)
    }
}

struct NotificationToggle: View {
    @Binding var isEnabled: Bool  // Two-way connection to parent

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}
```

**For @Observable objects, use @Bindable:**

```swift
struct ProfileEditor: View {
    @Bindable var profile: UserProfile  // Creates bindings to @Observable

    var body: some View {
        TextField("Name", text: $profile.name)
    }
}
```

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
