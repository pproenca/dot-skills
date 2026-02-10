---
title: Use SF Symbols with Correct Rendering Mode and Weight
impact: HIGH
impactDescription: saves 10-50KB per icon — SF Symbols scale with Dynamic Type automatically while custom assets require manual sizing at each breakpoint
tags: vis, sf-symbols, icons, rendering-mode, weight
---

## Use SF Symbols with Correct Rendering Mode and Weight

SF Symbols scale with Dynamic Type, match system font weight, and support multiple rendering modes. Using custom image assets for standard icons wastes bundle size and breaks visual consistency.

**Incorrect (custom images or mismatched symbols):**

```swift
// Custom asset instead of SF Symbol
Image("custom-heart-icon")
    .resizable()
    .frame(width: 24, height: 24) // doesn't scale with Dynamic Type

// Symbol weight doesn't match adjacent text
HStack {
    Image(systemName: "star.fill")
        .font(.system(size: 24, weight: .ultraLight)) // mismatch
    Text("Favorites")
        .font(.headline) // .headline is semibold
}
```

**Correct (SF Symbols with proper configuration):**

```swift
// Symbol scales with text automatically
Label("Favorites", systemImage: "star.fill")
    .font(.headline) // symbol inherits weight and size

// Explicit rendering mode for multi-color icons
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor) // shows natural colors

// Hierarchical rendering for depth
Image(systemName: "square.stack.3d.up")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.blue)
```

**Rendering modes:**
| Mode | Usage |
|------|-------|
| `.monochrome` | Single color, default |
| `.hierarchical` | Primary color with depth layers |
| `.palette` | Two or more custom colors |
| `.multicolor` | Fixed Apple-designed colors |

**Symbol effects (iOS 17+):**

```swift
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative) // animated signal bars

Image(systemName: "checkmark.circle")
    .symbolEffect(.bounce, value: isComplete) // bounce on change
```

Reference: [SF Symbols - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
