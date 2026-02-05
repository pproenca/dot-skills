---
title: Add Accessibility Labels to Interactive Elements
impact: MEDIUM-HIGH
impactDescription: enables VoiceOver users to understand controls
tags: acc, accessibility, voiceover, labels, screen-reader
---

## Add Accessibility Labels to Interactive Elements

VoiceOver reads accessibility labels to describe UI elements. Without them, users hear unhelpful descriptions like "button" or "image".

**Incorrect (no labels):**

```swift
struct SocialActions: View {
    var body: some View {
        HStack {
            Button { like() } label: {
                Image(systemName: "heart")  // VoiceOver: "heart, button"
            }
            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")  // Unhelpful
            }
            Button { bookmark() } label: {
                Image(systemName: "bookmark")  // "bookmark, button"
            }
        }
    }
}
```

**Correct (descriptive labels):**

```swift
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

Slider(value: $volume)
    .accessibilityValue("\(Int(volume * 100)) percent")

TextField("Search", text: $query)
    .accessibilityLabel("Search recipes")
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

Reference: [Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
