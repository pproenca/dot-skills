---
title: Use Semantic and System Colors
impact: CRITICAL
impactDescription: automatic Dark Mode support, accessibility compliance, and visual consistency with iOS
tags: design, colors, dark-mode, accessibility, semantic, accent, interactive
---

## Use Semantic and System Colors

Semantic colors like `.primary`, `.secondary`, and system backgrounds automatically adapt to Dark Mode, accessibility settings, and platform conventions. System accent colors are optimized for legibility on both light and dark backgrounds.

**Incorrect (hardcoded colors):**

```swift
struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .foregroundColor(Color(red: 0, green: 0, blue: 0))  // Black, invisible in Dark Mode
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))  // Light gray, wrong in Dark Mode
    }
}
```

**Correct (semantic colors):**

```swift
// SwiftUI
struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .foregroundStyle(.primary)  // Adapts to color scheme
            .background(.background.secondary)  // System background
    }
}

// UIKit
label.textColor = UIColor.label
view.backgroundColor = UIColor.systemBackground
```

**Semantic color hierarchy (SwiftUI):**

```swift
// Text colors (ShapeStyle)
.primary      // Main text, high contrast
.secondary    // Supporting text, medium contrast
.tertiary     // Placeholder text, low contrast
.quaternary   // Disabled text, minimal contrast

// Background colors (iOS 17+ ShapeStyle)
.background           // Primary background
.background.secondary // Grouped content background

// Bridging UIKit system colors into SwiftUI
Color(.systemBackground)           // Primary background
Color(.secondarySystemBackground)  // Secondary background
Color(.tertiarySystemBackground)   // Tertiary background
Color(.systemGroupedBackground)    // Grouped table background
```

**UIKit semantic colors (for bridging):**
- Labels: `UIColor.label`, `.secondaryLabel`, `.tertiaryLabel`, `.quaternaryLabel`
- Backgrounds: `UIColor.systemBackground`, `.secondarySystemBackground`, `.tertiarySystemBackground`
- Fills: `UIColor.systemFill`, `.secondarySystemFill`, `.tertiarySystemFill`
- Groups: `UIColor.systemGroupedBackground`, `.secondarySystemGroupedBackground`

**System accent colors for interactive elements:**

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

**Defining custom adaptive colors:**

```swift
extension Color {
    static let cardBackground = Color("CardBackground")  // From asset catalog
}

// Asset catalog provides light and dark variants
```

Reference: [Human Interface Guidelines - Color](https://developer.apple.com/design/human-interface-guidelines/color)
