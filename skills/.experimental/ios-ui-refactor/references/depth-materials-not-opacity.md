---
title: Use System Materials, Not Custom Semi-Transparent Backgrounds
impact: HIGH
impactDescription: custom opacity backgrounds break vibrancy, ignore dark mode, and bypass accessibility settings — system materials adapt automatically for 100% of appearance configurations without a single line of conditional code
tags: depth, materials, blur, dark-mode, vibrancy, accessibility
---

## Use System Materials, Not Custom Semi-Transparent Backgrounds

`.background(Color.black.opacity(0.3))` is not a material — it is a flat tint that obscures content without adapting to anything. It produces different visual results depending on what sits behind it, never generates vibrancy for foreground labels, and looks muddy in dark mode. System materials use a multi-layer blur with saturation and luminance adjustments that Apple calibrates per device and appearance. Apple Weather places every card over dynamic animated backgrounds using `.ultraThinMaterial` precisely because no hand-tuned opacity value can match the readability a material provides.

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
