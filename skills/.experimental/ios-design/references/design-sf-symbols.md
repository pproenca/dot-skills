---
title: Use SF Symbols for Consistent Iconography
impact: HIGH
impactDescription: 6900+ icons that scale with text, adapt to context, and match system UI
tags: design, sf-symbols, icons, system, consistency
---

## Use SF Symbols for Consistent Iconography

SF Symbols are Apple's icon system. They automatically scale with Dynamic Type, adapt to weight, support multiple rendering modes, and match iOS system appearance perfectly.

**Incorrect (custom image assets):**

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

**Symbol configuration:**

```swift
// Weight matches text weight
Image(systemName: "star.fill")
    .fontWeight(.semibold)

// Size matches text style
Image(systemName: "heart")
    .font(.title)

// Explicit size with scaling
Image(systemName: "gear")
    .imageScale(.large)  // .small, .medium, .large
```

**Rendering modes:**

```swift
// Monochrome (default) - single color
Image(systemName: "cloud.sun.fill")
    .foregroundStyle(.blue)

// Hierarchical - automatic depth
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.blue)

// Palette - custom colors per layer
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.gray, .yellow)

// Multicolor - Apple's designed colors
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)
```

**Symbol variants:**

```swift
// Fill variant
Image(systemName: "heart.fill")

// Slash variant (disabled state)
Image(systemName: "bell.slash")

// Badge variant
Image(systemName: "app.badge")

// Using symbolVariant modifier
Image(systemName: "heart")
    .symbolVariant(.fill)
```

**SF Symbol best practices:**
- Tab bars prefer `.fill` variant
- Toolbars prefer outline variant
- Use `symbolRenderingMode(.hierarchical)` for depth
- Match symbol weight to adjacent text weight
- Use `symbolVariant(.fill)` for selected states

**Finding symbols:** Use SF Symbols app (free from Apple) to browse all 6,900+ symbols.

Reference: [SF Symbols Documentation](https://developer.apple.com/sf-symbols/)
