---
title: Add VoiceOver Labels to Interactive Elements
impact: HIGH
impactDescription: "enables VoiceOver navigation for 100% of interactive elements; required for App Store accessibility"
tags: access, voiceover, accessibility, labels, hints
---

## Add VoiceOver Labels to Interactive Elements

Every interactive element needs a descriptive accessibility label. Without labels, VoiceOver reads raw image names or nothing at all, making your app unusable for visually impaired users.

**Incorrect (missing or unhelpful labels):**

```swift
// Icon-only button with no label
Button {
    toggleFavorite()
} label: {
    Image(systemName: "heart.fill")
}
// VoiceOver reads: "heart fill" - meaningless

// Image with no description
Image("hero-banner")
// VoiceOver reads: "hero banner" - unhelpful
```

**Correct (descriptive accessibility labels):**

```swift
// Labeled icon button
Button {
    toggleFavorite()
} label: {
    Image(systemName: isFavorite ? "heart.fill" : "heart")
}
.accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")

// Decorative image hidden from VoiceOver
Image("hero-banner")
    .accessibilityHidden(true)

// Informational image with description
Image("chart-revenue")
    .accessibilityLabel("Revenue chart showing 23% growth over 6 months")
```

**Group related elements into single VoiceOver stops:**

```swift
HStack {
    Image(systemName: "star.fill")
    Text("4.8")
    Text("(2,341 reviews)")
}
.accessibilityElement(children: .combine)
// VoiceOver reads as one: "star fill, 4.8, 2341 reviews"

// Or with a custom label
HStack {
    Image(systemName: "star.fill")
    Text("4.8")
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Rating: 4.8 out of 5 stars")
```

**Add hints for non-obvious interactions:**

```swift
Button("Order") { placeOrder() }
    .accessibilityHint("Double-tap to place your order and proceed to payment")
```

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
