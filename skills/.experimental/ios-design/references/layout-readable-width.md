---
title: Constrain Text to Readable Width on iPad
impact: HIGH
impactDescription: prevents uncomfortably long lines of text on large screens
tags: layout, readability, ipad, text-width
---

## Constrain Text to Readable Width on iPad

On iPad, constrain text content to a readable width (about 70-80 characters per line). Don't let text span the full screen width as it becomes difficult to read.

**Incorrect (text spans full width on iPad):**

```swift
// Text becomes too wide on iPad
ScrollView {
    VStack(alignment: .leading) {
        Text(longArticleText)
            .padding()
    }
}
// Results in 150+ character lines on iPad landscape
```

**Correct (constrained readable width):**

```swift
// Using readableContentGuide
ScrollView {
    VStack(alignment: .leading) {
        Text(longArticleText)
    }
    .frame(maxWidth: .readableContentMaxWidth)
    .padding(.horizontal)
}

// UIKit equivalent
textView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    textView.leadingAnchor.constraint(
        equalTo: view.readableContentGuide.leadingAnchor),
    textView.trailingAnchor.constraint(
        equalTo: view.readableContentGuide.trailingAnchor)
])

// Manual max width for custom layouts
Text(content)
    .frame(maxWidth: 672) // ~70 chars at body size
```

**Readable width behavior:**
- iPhone: Full width (already narrow enough)
- iPad Portrait: Constrained to ~672pt
- iPad Landscape: Constrained, centered

**When NOT to constrain:**
- Data tables
- Image galleries
- Dashboard layouts
- Navigation elements

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
