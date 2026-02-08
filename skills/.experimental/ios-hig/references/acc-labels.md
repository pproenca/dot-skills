---
title: Provide Meaningful Accessibility Labels
impact: CRITICAL
impactDescription: makes app usable for blind and low-vision users via VoiceOver
tags: acc, accessibility, voiceover, labels, screen-reader
---

## Provide Meaningful Accessibility Labels

Every interactive element needs a meaningful accessibility label. VoiceOver reads these labels to describe UI elements. Without them, users hear unhelpful descriptions like "button" or "image". Labels should describe what the element does, not what it looks like.

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

// Icon buttons without descriptive labels
struct SocialActions: View {
    var body: some View {
        HStack {
            Button { like() } label: {
                Image(systemName: "heart")  // VoiceOver: "heart, button"
            }
            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")  // Unhelpful
            }
        }
    }
}
```

**Correct (meaningful accessibility labels):**

```swift
// Describes the action with state
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

// Descriptive labels for icon buttons
struct SocialActions: View {
    let isLiked: Bool
    let isBookmarked: Bool

    var body: some View {
        HStack {
            Button { like() } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
            }
            .accessibilityLabel(isLiked ? "Unlike" : "Like")

            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .accessibilityLabel("Share")
            .accessibilityHint("Opens share sheet to share this item")

            Button { bookmark() } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
            }
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")
        }
    }
}
```

**Common accessibility modifiers:**

```swift
Image("profile-photo")
    .accessibilityLabel("Profile photo of \(user.name)")

Button("X") { dismiss() }
    .accessibilityLabel("Close")
    .accessibilityHint("Dismisses this screen")

TextField("Search", text: $query)
    .accessibilityLabel("Search recipes")
```

**Combine related elements:**

```swift
HStack {
    Image("user-avatar")
    VStack(alignment: .leading) {
        Text(user.name)
        Text(user.email)
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(user.name), \(user.email)")
```

**Hiding decorative elements:**

```swift
// Decorative images don't need VoiceOver
Image("decorative-divider")
    .accessibilityHidden(true)

// Group related elements
VStack {
    Image(systemName: "star.fill")
    Text("4.5")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Rating: 4.5 stars")
```

**Label guidelines:**
- Describe function, not appearance
- Include state ("selected", "expanded")
- Use hints sparingly (for non-obvious actions)
- Hide purely decorative elements
- Test with VoiceOver enabled

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
