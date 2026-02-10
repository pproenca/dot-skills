---
title: Show Scroll Indicators for Long Content
impact: LOW
impactDescription: controls scroll indicator visibility; prevents visual clutter in custom UIs
tags: layout, scroll, indicators, navigation
---

## Show Scroll Indicators for Long Content

Keep scroll indicators visible (at least initially) so users know there's more content. Don't hide them permanently, but they can fade after interaction.

**Incorrect (hidden scroll indicators):**

```swift
// Completely hidden - users don't know there's more
ScrollView {
    VStack {
        // long content
    }
}
.scrollIndicators(.hidden) // Bad for long content

// No indication of additional content
List(manyItems) { item in
    ItemRow(item: item)
}
.scrollIndicators(.never) // Users might miss items
```

**Correct (appropriate scroll indicators):**

```swift
// Default behavior - indicators appear and fade
ScrollView {
    VStack {
        // content
    }
}
// No modifier needed - default is appropriate

// Persistent indicators for very long content
ScrollView {
    LazyVStack {
        ForEach(0..<1000) { i in
            Text("Item \(i)")
        }
    }
}
.scrollIndicators(.visible, axes: .vertical)

// Hidden only for short content that fits
ScrollView(.horizontal) {
    HStack {
        ForEach(0..<3) { i in
            CardView()
        }
    }
}
.scrollIndicators(.hidden) // OK - content is short

// Scroll position indicator for long documents
ScrollView {
    Text(longDocument)
}
.scrollPosition(id: $scrollPosition)
// Consider adding a minimap or progress indicator
```

**Scroll indicator guidelines:**
- Default (automatic) is usually best
- Show for long lists and documents
- Can hide for short, obvious content
- Consider scroll-to-top button for very long lists
- Section index for alphabetized lists

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
