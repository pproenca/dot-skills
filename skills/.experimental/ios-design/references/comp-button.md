---
title: Use Appropriate Button Styles and Controls
impact: HIGH
impactDescription: communicates button importance, creates visual hierarchy, and prevents control confusion
tags: comp, button, toggle, switch, control, styles, actions
---

## Use Appropriate Button Styles and Controls

Use SwiftUI button styles to communicate importance: `.borderedProminent` for primary actions, `.bordered` for secondary, and plain for tertiary. Buttons trigger actions; Toggles change state. Users have strong expectations about how each behaves.

**Incorrect (no visual hierarchy, wrong control type):**

```swift
// All buttons look the same
VStack {
    Button("Submit Order") { }
    Button("Save for Later") { }
    Button("Cancel") { }
}
// User can't identify the primary action

// Button for on/off state
Button(isMuted ? "Unmute" : "Mute") {
    isMuted.toggle()
}
// Label changes, confusing which state is active
```

**Correct (clear button hierarchy):**

```swift
VStack(spacing: 16) {
    // Primary action - most prominent
    Button("Submit Order") {
        submitOrder()
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)

    // Secondary action
    Button("Save for Later") {
        saveForLater()
    }
    .buttonStyle(.bordered)

    // Tertiary/cancel action
    Button("Cancel", role: .cancel) {
        dismiss()
    }
    .buttonStyle(.plain)
}

// Destructive action
Button("Delete Account", role: .destructive) {
    deleteAccount()
}
.buttonStyle(.borderedProminent)
// Automatically uses red tint for destructive role
```

**Use Toggle for persistent settings:**

```swift
struct NotificationSettings: View {
    @AppStorage("pushEnabled") private var pushEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        Form {
            Toggle("Push Notifications", isOn: $pushEnabled)
            Toggle("Sound Effects", isOn: $soundEnabled)
        }
    }
}
```

**Button style hierarchy:**
| Style | Usage | Appearance |
|-------|-------|------------|
| `.borderedProminent` | Primary action | Filled, tinted |
| `.bordered` | Secondary action | Outlined |
| `.plain` | Tertiary, links | Text only |
| `.borderless` | In-context actions | Text, no chrome |

**Control sizes:**
- `.small` - Compact spaces, lists
- `.regular` - Default
- `.large` - Full-width primary actions

**Decision matrix (Button vs Toggle):**

| Interaction | Control |
|-------------|---------|
| Submit form | Button |
| Delete item | Button |
| Enable/disable feature | Toggle |
| On/off setting | Toggle |

Reference: [Buttons - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/buttons)
