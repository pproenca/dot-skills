---
title: Use Semantic System Colors
impact: CRITICAL
impactDescription: automatic Dark Mode support and accessibility compliance
tags: design, colors, dark-mode, accessibility, semantic
---

## Use Semantic System Colors

Semantic colors like `.primary`, `.secondary`, and system backgrounds automatically adapt to Dark Mode, accessibility settings, and platform conventions.

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
struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .foregroundStyle(.primary)  // Adapts to color scheme
            .background(.background.secondary)  // System background
    }
}
```

**Semantic color hierarchy:**

```swift
// Text colors
.primary      // Main text, high contrast
.secondary    // Supporting text, medium contrast
.tertiary     // Placeholder text, low contrast
.quaternary   // Disabled text, minimal contrast

// Background colors
.background           // Primary background
.background.secondary // Grouped content background

// System colors (adapt to Dark Mode)
Color.systemBackground
Color.secondarySystemBackground
Color.tertiarySystemBackground
Color.systemGroupedBackground

// Accent colors
Color.accentColor  // App tint color
Color.blue, .green, .red  // System colors with Dark Mode variants
```

**Defining custom adaptive colors:**

```swift
extension Color {
    static let cardBackground = Color("CardBackground")  // From asset catalog
}

// Asset catalog provides light and dark variants
```

Reference: [Human Interface Guidelines - Color](https://developer.apple.com/design/human-interface-guidelines/color)
