---
title: Support Dynamic Type for All Text
impact: CRITICAL
impactDescription: enables users to read text at their preferred size
tags: a11y, dynamic-type, font-scaling, readability
---

## Support Dynamic Type for All Text

All text must scale with Dynamic Type settings. Users with low vision may need text up to 310% larger. Layouts must accommodate this without truncation.

**Incorrect (fixed font sizes):**

```swift
// Fixed size ignores user preferences
Text("Hello")
    .font(.system(size: 17))

// Layout breaks at larger sizes
HStack {
    Text("Long label text here")
        .font(.body)
    Spacer()
    Text("Value")
        .lineLimit(1) // Truncates at large sizes
}

// Fixed frame truncates
Text(title)
    .frame(height: 44) // Too small for large text
```

**Correct (scales with Dynamic Type):**

```swift
// Use text styles
Text("Hello")
    .font(.body)

// Layout adapts to text size
@ScaledMetric var spacing: CGFloat = 8

VStack(alignment: .leading, spacing: spacing) {
    Text("Long label text here")
        .font(.body)
    Text("Value")
        .font(.body)
        .foregroundColor(.secondary)
}

// Flexible layout
ViewThatFits {
    HStack {
        Text(label)
        Spacer()
        Text(value)
    }
    VStack(alignment: .leading) {
        Text(label)
        Text(value)
            .foregroundColor(.secondary)
    }
}

// Scaled image sizes
@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 24

Image(systemName: "star")
    .font(.system(size: iconSize))

// UIKit Dynamic Type
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
label.numberOfLines = 0 // Allow wrapping
```

**Testing Dynamic Type:**
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Enable "Larger Accessibility Sizes"
3. Test at largest size (AX5)

**Accessibility categories:**
- xSmall through xxxLarge (7 sizes)
- AX1 through AX5 (5 more for accessibility)

Reference: [Typography - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
