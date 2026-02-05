---
title: Use SF Symbols for Consistent Iconography
impact: MEDIUM
impactDescription: 6900+ icons that scale with text and adapt to context
tags: platform, sf-symbols, icons, system, consistency
---

## Use SF Symbols for Consistent Iconography

SF Symbols are Apple's icon system. They automatically scale with Dynamic Type, adapt to weight, and support multiple rendering modes.

**Incorrect (custom image assets):**

```swift
struct ActionButton: View {
    var body: some View {
        Button {
            share()
        } label: {
            Image("share-icon")  // Custom asset, doesn't scale
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
}
```

**Correct (SF Symbols):**

```swift
struct ActionButton: View {
    var body: some View {
        Button {
            share()
        } label: {
            Image(systemName: "square.and.arrow.up")  // Scales automatically
        }
    }
}
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

**Finding symbols:** Use SF Symbols app (free from Apple) to browse all 6900+ symbols.

Reference: [SF Symbols Documentation](https://developer.apple.com/sf-symbols/)
