---
title: Add VoiceOver Labels to Every Interactive Element
impact: CRITICAL
impactDescription: each unlabeled element is a 100% task-failure for VoiceOver users — proper labels fix 60-90% of WCAG 2.1 Level A violations and reduce accessibility audit findings by 3-5× per screen
tags: empathy, voiceover, accessibility, kocienda-empathy, edson-people, a11y
---

## Add VoiceOver Labels to Every Interactive Element

Kocienda describes empathy as creating work that fits into other people's lives. For a blind user, your app's entire interface is mediated through VoiceOver — if a button reads "heart fill" instead of "Add to favorites," you have communicated nothing. Edson's "design is about people" includes the person who will never see your beautiful gradient but still deserves to use your app with the same confidence as a sighted user. Every interactive element without a descriptive label is a door you've locked.

**Incorrect (missing or unhelpful labels):**

```swift
struct BookmarkButton: View {
    @Binding var isBookmarked: Bool

    var body: some View {
        Button {
            isBookmarked.toggle()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
        }
        // VoiceOver reads: "bookmark fill" — meaningless
    }
}

// Decorative image that wastes VoiceOver time
Image("hero-banner")
// VoiceOver reads: "hero banner" — unhelpful noise
```

**Correct (descriptive labels and intentional hiding):**

```swift
struct BookmarkButton: View {
    @Binding var isBookmarked: Bool

    var body: some View {
        Button {
            isBookmarked.toggle()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
        }
        .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")
    }
}

// Decorative image hidden from VoiceOver
Image("hero-banner")
    .accessibilityHidden(true)

// Informational image with meaningful description
Image("revenue-chart")
    .accessibilityLabel("Revenue chart showing 23% growth over 6 months")
```

**Group related elements into single VoiceOver stops:**

```swift
HStack(spacing: 4) {
    Image(systemName: "star.fill")
        .foregroundStyle(.orange)
    Text("4.8")
    Text("(2,341 reviews)")
        .foregroundStyle(.secondary)
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Rating: 4.8 out of 5 stars, 2,341 reviews")
```

**Accessibility audit checklist:**
- Every `Button` with an icon-only label has `.accessibilityLabel`
- Every decorative `Image` has `.accessibilityHidden(true)`
- Every informational `Image` has `.accessibilityLabel` describing its content
- Related elements are grouped with `.accessibilityElement(children:)`
- Actions include `.accessibilityHint` when the result is non-obvious

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
