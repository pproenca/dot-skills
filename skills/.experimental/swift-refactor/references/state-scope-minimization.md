---
title: Minimize State Scope to Nearest Consumer
impact: CRITICAL
impactDescription: 2-5x fewer re-renders by scoping state to leaf views
tags: state, scope, re-renders, performance, refactoring
---

## Minimize State Scope to Nearest Consumer

When @State is declared in a parent view, every change to that state invalidates the parent and all of its children, even if only one deeply nested child actually reads the value. Moving @State down to the view that consumes it confines invalidation to the smallest possible subtree, reducing re-renders by 2-5x in deep view hierarchies.

**Incorrect (state owned by parent forces entire subtree to re-render):**

```swift
struct SettingsScreen: View {
    @State private var preferences: [Preference] = []
    @State private var isBoldTextEnabled: Bool = false

    var body: some View {
        VStack {
            BoldTextToggle(isEnabled: $isBoldTextEnabled)
            PreferenceList(preferences: preferences)
            // Toggling isBoldTextEnabled invalidates SettingsScreen,
            // which re-renders PreferenceList even though it
            // never reads isBoldTextEnabled
        }
    }
}

struct BoldTextToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle("Bold Text", isOn: $isEnabled)
    }
}
```

**Correct (state scoped to the only view that consumes it):**

```swift
struct SettingsScreen: View {
    @State private var preferences: [Preference] = []

    var body: some View {
        VStack {
            BoldTextToggle()
            PreferenceList(preferences: preferences)
            // Toggle changes only invalidate BoldTextToggle
        }
    }
}

struct BoldTextToggle: View {
    @State private var isEnabled: Bool = false

    var body: some View {
        Toggle("Bold Text", isOn: $isEnabled)
    }
}
```

Reference: [Demystify SwiftUI performance - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
