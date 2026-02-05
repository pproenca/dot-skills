---
title: Add Accessibility Labels to Interactive Elements
impact: MEDIUM-HIGH
impactDescription: enables VoiceOver, required for inclusive apps, improves usability
tags: access, swiftui, accessibility, voiceover, labels, inclusive
---

## Add Accessibility Labels to Interactive Elements

Add `.accessibilityLabel()` to elements that don't have visible text. VoiceOver users need descriptive labels to understand interactive elements. All buttons, images, and custom controls need labels.

**Incorrect (missing accessibility):**

```swift
// Icon-only button without label
Button {
    addItem()
} label: {
    Image(systemName: "plus")
}
// VoiceOver says "button" - not helpful

// Decorative image announced as content
Image("logo")
// VoiceOver describes the image unnecessarily
```

**Correct (proper accessibility):**

```swift
// Button with accessibility label
Button {
    addFriend()
} label: {
    Image(systemName: "plus")
}
.accessibilityLabel("Add friend")

// Hide decorative images from VoiceOver
Image("decorative-divider")
    .accessibilityHidden(true)

// Informative image with description
Image("weather-sunny")
    .accessibilityLabel("Sunny weather")

// Combined element with custom description
HStack {
    Image(systemName: "star.fill")
    Text("\(rating)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(rating) stars")

// Accessibility hint for complex interactions
Button("Delete") {
    showDeleteConfirmation()
}
.accessibilityHint("Shows confirmation dialog")
```

**Accessibility modifiers:**
- `.accessibilityLabel()` - What the element is
- `.accessibilityHint()` - What happens on activation
- `.accessibilityHidden(true)` - Hide decorative elements
- `.accessibilityElement(children:)` - Combine or ignore children

Reference: [Develop in Swift Tutorials - Add inclusive features](https://developer.apple.com/tutorials/develop-in-swift/add-inclusive-features)
