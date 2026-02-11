---
title: Source Color Tokens from Asset Catalog, Not Code
impact: CRITICAL
impactDescription: asset catalog provides automatic light/dark adaptation, Xcode visual preview, and designer-friendly editing — code-defined colors lose all three
tags: token, asset-catalog, color, dark-mode, xcassets
---

## Source Color Tokens from Asset Catalog, Not Code

The asset catalog (`.xcassets`) is Apple's designated system for managing color values across appearances (light, dark, high contrast) and platforms (iOS, macOS, visionOS). When you define color values in code, you lose Xcode's visual color preview, the ability for designers to inspect and adjust values without opening Swift files, automatic trait-based resolution, and Accessibility Inspector integration. The correct pattern is: asset catalog holds the VALUES, Swift extensions provide the API.

**Incorrect (color values defined entirely in code):**

```swift
extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color {
        // Manually switching on color scheme — fragile, misses high contrast
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)  // #1C1C1E
                : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)  // #F2F2F7
        })
    }

    static var textPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.10, green: 0.10, blue: 0.18, alpha: 1)
        })
    }

    // 15 more colors, each with manual dark mode switching...
}
```

**Correct (asset catalog holds values, Swift provides the API):**

```text
Colors.xcassets/
├── Background/
│   ├── backgroundPrimary.colorset/
│   │   └── Contents.json          // Any: #F2F2F7, Dark: #1C1C1E
│   ├── backgroundSurface.colorset/
│   │   └── Contents.json          // Any: #FFFFFF, Dark: #2C2C2E
│   └── backgroundElevated.colorset/
│       └── Contents.json          // Any: #FFFFFF, Dark: #3A3A3C
├── Text/
│   ├── textPrimary.colorset/
│   │   └── Contents.json          // Any: #1A1A2E, Dark: #FFFFFF
│   └── textSecondary.colorset/
│       └── Contents.json          // Any: #8E8E93, Dark: #AEAEB2
└── Brand/
    └── accentPrimary.colorset/
        └── Contents.json          // Any: #5856D6, Dark: #7D7AFF
```

```swift
// Colors.swift — thin API layer, no values
import SwiftUI

extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var backgroundElevated: Color { Color("backgroundElevated") }
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var accentPrimary: Color { Color("accentPrimary") }
}

// Usage — identical regardless of light/dark/high-contrast
struct ListingCard: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(property.name)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            Text(property.location)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
        .padding()
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**High Contrast support (automatic with asset catalog):**

```text
backgroundPrimary.colorset/Contents.json
├── Any Appearance         → #F2F2F7
├── Dark                   → #1C1C1E
├── High Contrast (Any)    → #FFFFFF   // Maximum contrast for accessibility
└── High Contrast (Dark)   → #000000   // Maximum contrast in dark mode
```

No code changes needed — the asset catalog resolves the correct variant based on the user's accessibility settings automatically.

**When code-defined colors are acceptable:**
- Ephemeral, non-semantic colors (e.g., a one-off gradient stop in an animation)
- Colors derived from user-generated content (e.g., extracted from an image)
- Colors computed from other tokens (e.g., `.opacity(0.5)` applied to a semantic token)

**Benefits:**
- Xcode shows color swatches inline in the asset catalog editor — designers can review without reading Swift
- Dark mode, high contrast, and elevated contrast variants are managed visually
- Accessibility Inspector reads asset catalog colors directly
- `Color("name")` resolution is optimized by the asset catalog compiler at build time

Reference: [Asset Catalog Colors — Apple Developer](https://developer.apple.com/documentation/xcode/asset-management), [WWDC22 — What's new in Xcode](https://developer.apple.com/videos/play/wwdc2022/110427/)
