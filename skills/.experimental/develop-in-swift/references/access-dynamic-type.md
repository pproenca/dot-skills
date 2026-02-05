---
title: Support Dynamic Type for All Text
impact: MEDIUM-HIGH
impactDescription: respects user font size settings, required for accessibility, improves readability
tags: access, swiftui, accessibility, dynamic-type, fonts, scaling
---

## Support Dynamic Type for All Text

Use semantic font styles (`.title`, `.body`, `.caption`) instead of fixed sizes. SwiftUI automatically scales text based on user's accessibility settings. Test with larger text sizes.

**Incorrect (fixed font sizes):**

```swift
// Hard-coded sizes don't scale
Text("Title")
    .font(.system(size: 24))  // Won't respect Dynamic Type

Text("Body text")
    .font(.system(size: 14))  // Fixed size
```

**Correct (semantic text styles):**

```swift
// Semantic styles scale automatically
Text("Welcome")
    .font(.largeTitle)

Text("Section Header")
    .font(.headline)

Text("This is the main content of the app.")
    .font(.body)

Text("Additional details")
    .font(.caption)

// Allow text to scale with custom fonts
Text("Custom")
    .font(.custom("Avenir", size: 18, relativeTo: .body))

// Limit scaling for specific layouts
Text("Tab Label")
    .font(.caption2)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Cap scaling
```

**Semantic font styles (smallest to largest):**
- `.caption2`, `.caption` - Smallest
- `.footnote`, `.subheadline`
- `.body` - Default reading size
- `.headline`, `.title3`, `.title2`, `.title`
- `.largeTitle` - Largest

**Testing Dynamic Type:**
- Use Xcode previews with different size classes
- Environment override in preview: `.environment(\.sizeCategory, .accessibilityExtraExtraLarge)`

Reference: [Develop in Swift Tutorials - Add inclusive features](https://developer.apple.com/tutorials/develop-in-swift/add-inclusive-features)
