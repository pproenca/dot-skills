---
title: Use System Materials, Not Custom Semi-Transparent Backgrounds
impact: HIGH
impactDescription: custom opacity backgrounds break vibrancy, ignore dark mode, and bypass accessibility settings — system materials adapt automatically for 100% of appearance configurations
tags: invisible, materials, blur, rams-5, edson-product, dark-mode
---

## Use System Materials, Not Custom Semi-Transparent Backgrounds

Rams compared good products to neutral tools — they leave room for the user's self-expression. Hand-tuned opacity backgrounds call attention to themselves; system materials disappear, letting content remain the focus. Edson's principle that the product is the marketing means the quality of the material system speaks for itself without the developer manually calibrating blur values.

**Incorrect (hand-tuned opacity that ignores appearance and vibrancy):**

```swift
struct WeatherCard: View {
    let temperature: String
    let condition: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(temperature)
                .font(.system(size: 48, weight: .thin))

            Text(condition)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // Flat tint — no blur, no vibrancy, breaks in dark mode
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (system material with automatic adaptation):**

```swift
struct WeatherCard: View {
    let temperature: String
    let condition: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(temperature)
                .font(.system(.largeTitle, design: .rounded, weight: .thin))
                .foregroundStyle(.primary)

            Text(condition)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Material selection guide:**
- `.ultraThinMaterial` — high-contrast backgrounds (vivid photos, gradients, video). Maximum background visibility.
- `.thinMaterial` — moderately busy backgrounds. Good default for overlaid cards.
- `.regularMaterial` — general-purpose. Equivalent to the system navigation bar blur.
- `.thickMaterial` / `.ultraThickMaterial` — low-contrast or text-heavy backgrounds where readability is critical.
- `.bar` — matches the exact treatment of system toolbars and tab bars.

**When NOT to use:** Solid-color backgrounds where no content sits behind the layer. Materials over a plain white background waste GPU compositing for zero visual benefit — use `Color(.secondarySystemBackground)` instead.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC21 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/) (material modifiers)
