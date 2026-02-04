---
title: Provide Meaningful VoiceOver Labels
impact: CRITICAL
impactDescription: makes app usable for blind and low-vision users
tags: a11y, voiceover, labels, screen-reader
---

## Provide Meaningful VoiceOver Labels

Every interactive element needs a meaningful accessibility label. Labels should describe what the element does, not what it looks like.

**Incorrect (missing or poor labels):**

```swift
// No label - VoiceOver says "button"
Button {
    toggleFavorite()
} label: {
    Image(systemName: "heart")
}

// Label describes appearance, not function
Button {
    toggleFavorite()
} label: {
    Image(systemName: "heart")
}
.accessibilityLabel("Heart icon")

// Missing label on icon-only elements
Image(systemName: "info.circle")
    .onTapGesture { showInfo() }
// VoiceOver can't interact with this
```

**Correct (meaningful accessibility labels):**

```swift
// Describes the action
Button {
    toggleFavorite()
} label: {
    Image(systemName: isFavorite ? "heart.fill" : "heart")
}
.accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")

// Include state information
Toggle("Notifications", isOn: $notificationsEnabled)
// SwiftUI handles "on/off" state automatically

// Custom value for complex controls
Slider(value: $volume, in: 0...100)
    .accessibilityLabel("Volume")
    .accessibilityValue("\(Int(volume)) percent")

// Combine related elements
HStack {
    Image("user-avatar")
    VStack(alignment: .leading) {
        Text(user.name)
        Text(user.email)
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(user.name), \(user.email)")

// Hide decorative elements
Image("decorative-line")
    .accessibilityHidden(true)

// Custom action descriptions
Button {
    shareItem()
} label: {
    Image(systemName: "square.and.arrow.up")
}
.accessibilityLabel("Share")
.accessibilityHint("Opens share sheet to share this item")
```

**Label guidelines:**
- Describe function, not appearance
- Include state ("selected", "expanded")
- Use hints sparingly (for non-obvious actions)
- Hide purely decorative elements
- Test with VoiceOver enabled

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
