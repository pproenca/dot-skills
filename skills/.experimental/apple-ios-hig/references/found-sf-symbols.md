---
title: Use SF Symbols for System-Consistent Icons
impact: HIGH
impactDescription: provides consistent, scalable icons that match system UI
tags: found, sf-symbols, images, system-icons
---

## Use SF Symbols for System-Consistent Icons

Use SF Symbols for icons whenever possible. They scale with Dynamic Type, adapt to font weights, and match iOS system appearance perfectly.

**Incorrect (custom icons that don't scale):**

```swift
// Fixed-size custom image
Image("custom-settings-icon")
    .resizable()
    .frame(width: 24, height: 24)

// Mismatched icon styling
HStack {
    Image(systemName: "gear")
        .font(.system(size: 20))
    Text("Settings")
        .font(.body) // Text scales, icon doesn't match
}
```

**Correct (SF Symbols that scale with text):**

```swift
// Symbol scales with text style
Label("Settings", systemImage: "gear")
    .font(.body)

// Symbol with matching weight
HStack {
    Image(systemName: "gear")
    Text("Settings")
}
.font(.headline)

// Symbol variants for different contexts
Image(systemName: "heart")          // Outline for toolbar
Image(systemName: "heart.fill")     // Fill for selected state
Image(systemName: "heart.circle")   // Circle for larger touch
```

**SF Symbol best practices:**
- Tab bars prefer `.fill` variant
- Toolbars prefer outline variant
- Use `symbolRenderingMode(.hierarchical)` for depth
- Match symbol weight to adjacent text weight
- Use `symbolVariant(.fill)` for selected states

**Finding symbols:**
Download SF Symbols app from Apple to browse 6,900+ symbols.

Reference: [SF Symbols - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
