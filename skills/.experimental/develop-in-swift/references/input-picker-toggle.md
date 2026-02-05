---
title: Use Picker and Toggle for Selection Input
impact: MEDIUM-HIGH
impactDescription: standard iOS controls, automatic styling, proper accessibility
tags: input, swiftui, picker, toggle, input, selection
---

## Use Picker and Toggle for Selection Input

Use `Picker` for choosing from multiple options and `Toggle` for on/off states. Both require bindings and automatically adapt to the context (forms, navigation, etc.).

**Incorrect (custom selection UI):**

```swift
// Don't build custom radio buttons
HStack {
    ForEach(options, id: \.self) { option in
        Button {
            selected = option
        } label: {
            Circle()
                .stroke(selected == option ? Color.blue : Color.gray)
        }
    }
}
```

**Correct (Picker and Toggle):**

```swift
// Picker for multiple choice
struct SettingsView: View {
    @State private var selectedColor = "Blue"
    @State private var notificationsEnabled = true

    var body: some View {
        Form {
            // Picker in Form shows as navigation
            Picker("Theme Color", selection: $selectedColor) {
                Text("Blue").tag("Blue")
                Text("Green").tag("Green")
                Text("Purple").tag("Purple")
            }

            // Toggle for boolean
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
        }
    }
}

// Picker styles
Picker("Size", selection: $size) {
    ForEach(sizes, id: \.self) { size in
        Text(size).tag(size)
    }
}
.pickerStyle(.segmented)  // Inline segmented control

Picker("Priority", selection: $priority) {
    // ...
}
.pickerStyle(.menu)  // Dropdown menu

// Toggle with custom label
Toggle(isOn: $isDarkMode) {
    Label("Dark Mode", systemImage: "moon.fill")
}
```

**Picker styles:**
- `.automatic` - Context-dependent (navigation in Form)
- `.segmented` - Inline segmented control
- `.menu` - Dropdown menu
- `.wheel` - iOS wheel picker

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)
