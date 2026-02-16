---
title: Use SF Symbols for Consistent Iconography
impact: HIGH
impactDescription: SF Symbols replace custom icon assets with 5,000+ system icons that auto-scale across 9 weights and 3 scales — saves 50-200KB per icon set and eliminates 3-5 lines of manual resizing/alignment code per icon usage
tags: system, icons, sf-symbols, kocienda-convergence, edson-systems, visual
---

## Use SF Symbols for Consistent Iconography

Edson's systems thinking demands that iconography participate in the same visual system as typography — icons must scale with text, match its weight, and adapt to accessibility settings. SF Symbols are that system: 5,000+ icons designed to integrate perfectly with San Francisco, supporting nine weights, three scales, and four rendering modes. Kocienda's convergence principle means using the icons that Apple's team already refined over thousands of iterations rather than introducing custom assets that break the visual coherence.

**Incorrect (custom image assets that don't scale with text):**

```swift
struct FeatureRow: View {
    var body: some View {
        HStack(spacing: 12) {
            // Custom PNG doesn't scale with Dynamic Type
            Image("custom-star-icon")
                .resizable()
                .frame(width: 24, height: 24)

            Text("Favorites")
                .font(.body)
        }
    }
}
```

**Correct (SF Symbols that scale and match text weight):**

```swift
struct FeatureRow: View {
    var body: some View {
        Label("Favorites", systemImage: "star.fill")
            .font(.body)
        // Icon automatically matches body weight and scales with Dynamic Type
    }
}
```

**SF Symbol rendering modes:**

```swift
// Monochrome — single color, matches foregroundStyle
Image(systemName: "bell.badge")
    .symbolRenderingMode(.monochrome)

// Hierarchical — primary color with automatic opacity layers
Image(systemName: "bell.badge")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.blue)

// Palette — multiple custom colors
Image(systemName: "bell.badge")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.blue, .red)

// Multicolor — Apple-designed fixed colors (e.g., weather symbols)
Image(systemName: "cloud.sun.rain.fill")
    .symbolRenderingMode(.multicolor)
```

**Symbol effects for state communication:**

```swift
// Bounce on tap
Image(systemName: "bell.fill")
    .symbolEffect(.bounce, value: notificationCount)

// Pulse for ongoing activity
Image(systemName: "network")
    .symbolEffect(.pulse, isActive: isConnecting)

// Replace for state change
Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    .contentTransition(.symbolEffect(.replace))
```

**When NOT to use SF Symbols:** Brand logos, product photography, complex illustrations, or icons that require exact pixel-level custom design. Use SF Symbols for functional UI icons, not decorative content.

Reference: [SF Symbols - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
