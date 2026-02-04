---
title: Use Appropriate Button Styles
impact: HIGH
impactDescription: communicates button importance and creates visual hierarchy
tags: comp, buttons, styles, actions
---

## Use Appropriate Button Styles

Use SwiftUI button styles to communicate importance: `.borderedProminent` for primary actions, `.bordered` for secondary, and plain for tertiary. Never make all buttons look the same.

**Incorrect (no visual hierarchy):**

```swift
// All buttons look the same
VStack {
    Button("Submit Order") { }
    Button("Save for Later") { }
    Button("Cancel") { }
}
// User can't identify the primary action

// Custom styling that doesn't match iOS
Button("Submit") { }
    .padding()
    .background(Color.purple)
    .cornerRadius(25)
    .shadow(radius: 10)
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

Reference: [Buttons - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/buttons)
