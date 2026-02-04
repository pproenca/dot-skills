---
title: Use System Accent Colors for Interactive Elements
impact: HIGH
impactDescription: maintains visual consistency with iOS system apps
tags: found, accent, interactive, branding
---

## Use System Accent Colors for Interactive Elements

Use system accent colors (`systemBlue`, `systemGreen`, `systemRed`, etc.) for interactive elements. These colors are optimized for legibility on both light and dark backgrounds.

**Incorrect (custom colors may have poor contrast):**

```swift
Button("Submit") {
    // action
}
.tint(Color(red: 0.2, green: 0.4, blue: 0.8)) // May not meet contrast

// Destructive with wrong color
Button("Delete", role: .destructive) {
    // action
}
.tint(.orange) // Users expect red for destructive
```

**Correct (system colors with proper semantics):**

```swift
// Primary action - uses app tint (defaults to systemBlue)
Button("Submit") {
    // action
}
.buttonStyle(.borderedProminent)

// Destructive action - automatically uses systemRed
Button("Delete", role: .destructive) {
    // action
}

// Custom but using system colors
Button("Archive") {
    // action
}
.tint(.systemOrange)
```

**System color semantics:**
- `systemBlue`: Primary actions, links, selections
- `systemGreen`: Success, positive status, completion
- `systemRed`: Errors, destructive actions, alerts
- `systemOrange`: Warnings, caution states
- `systemYellow`: Highlights, attention

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color)
