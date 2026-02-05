---
title: Use System Colors for Dark Mode Support
impact: HIGH
impactDescription: automatic dark mode, semantic meaning, accessibility compliant
tags: view, swiftui, colors, dark-mode, semantic, design
---

## Use System Colors for Dark Mode Support

Use semantic system colors like `.primary`, `.secondary`, and asset catalog colors. These automatically adapt to light and dark mode. Avoid hard-coded RGB values.

**Incorrect (hard-coded colors):**

```swift
// Hard-coded colors don't adapt to dark mode
Text("Title")
    .foregroundColor(Color(red: 0, green: 0, blue: 0))  // Black - invisible in dark mode

VStack {
    // ...
}
.background(Color.white)  // Harsh in dark mode
```

**Correct (semantic system colors):**

```swift
// Semantic colors adapt automatically
Text("Title")
    .foregroundStyle(.primary)  // Black in light, white in dark

Text("Subtitle")
    .foregroundStyle(.secondary)  // Gray that adapts

// System background colors
VStack {
    // ...
}
.background(Color(.systemBackground))

// Named colors from asset catalog
Text("Accent")
    .foregroundStyle(Color("BrandColor"))  // Define in Assets.xcassets

// Standard colors that adapt
Button("Delete", role: .destructive) { }  // Uses system red

Image(systemName: "star.fill")
    .foregroundStyle(.yellow)  // Standard yellow adapts

// Tint color (follows app accent)
Image(systemName: "globe")
    .foregroundStyle(.tint)
```

**System colors:**
- `.primary` / `.secondary` - Text colors
- `Color(.systemBackground)` - View backgrounds
- `Color(.secondarySystemBackground)` - Grouped content
- `.tint` - App accent color
- `.red`, `.blue`, `.green` - Standard colors (adapt slightly)

Reference: [Develop in Swift Tutorials - Design an interface](https://developer.apple.com/tutorials/develop-in-swift/design-an-interface)
