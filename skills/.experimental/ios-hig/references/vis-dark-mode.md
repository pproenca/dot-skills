---
title: Support Dark Mode with Semantic Colors
impact: HIGH
impactDescription: 80%+ of iOS users enable dark mode — hardcoded colors break readability for the majority of users
tags: vis, dark-mode, colors, semantic, appearance, color-scheme
---

## Support Dark Mode with Semantic Colors

Use system semantic colors (`.primary`, `.secondary`, `.background`) instead of hardcoded colors. Semantic colors automatically adapt to light and dark mode. Custom colors need both light and dark variants in the asset catalog.

**Incorrect (hardcoded colors break in dark mode):**

```swift
struct CardView: View {
    var body: some View {
        VStack {
            Text("Title")
                .foregroundColor(.black) // invisible on dark background
            Text("Subtitle")
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
        }
        .background(Color.white) // glaring white card in dark mode
    }
}
```

**Correct (semantic colors adapt automatically):**

```swift
struct CardView: View {
    var body: some View {
        VStack {
            Text("Title")
                .foregroundStyle(.primary) // adapts to light/dark
            Text("Subtitle")
                .foregroundStyle(.secondary)
        }
        .background(.background) // matches system background
    }
}
```

**Custom colors with asset catalog variants:**

```swift
// Define "BrandBlue" in Assets.xcassets with:
// - Any Appearance: #0066CC (dark blue)
// - Dark Appearance: #4DA6FF (lighter blue for dark backgrounds)

Text("Brand text")
    .foregroundStyle(Color("BrandBlue")) // auto-adapts

// Preview both modes
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
```

**Dark mode guidelines:**
- Never hardcode `.black`, `.white`, or RGB values for text/backgrounds
- Use `.primary`, `.secondary`, `.background`, `.accentColor`
- Test in both modes: use Xcode preview `.preferredColorScheme(.dark)`
- Custom colors: add dark variant in asset catalog

Reference: [Dark Mode - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
