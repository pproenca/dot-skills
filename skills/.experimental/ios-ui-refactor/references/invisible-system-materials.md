---
title: Use System Materials, Not Custom Semi-Transparent Backgrounds
impact: HIGH
impactDescription: custom opacity backgrounds break vibrancy, ignore dark mode, and bypass accessibility settings — system materials adapt automatically for 100% of appearance configurations
tags: invisible, materials, blur, rams-5, edson-product, dark-mode
---

## Use System Materials, Not Custom Semi-Transparent Backgrounds

There is a difference between a hand-tuned `Color.black.opacity(0.3)` overlay and `.ultraThinMaterial` that you can feel before you can explain. The hand-tuned value is a developer's best guess — it looks passable in light mode on one wallpaper, then falls apart in dark mode, or washes out over a bright photo, or ignores Increase Contrast entirely. It whispers "look at my clever blur." A system material says nothing at all. It simply lets content through at exactly the right density, adapts to every appearance setting automatically, and gets out of the way so you can focus on what is behind the glass. The craft is in choosing the material that disappears. Rams called this neutrality: a good tool leaves room for the user's world, never competing with it.

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

**When NOT to apply:** Solid-color backgrounds where no content sits behind the layer. Materials over a plain white background waste GPU compositing for zero visual benefit -- use `Color(.secondarySystemBackground)` instead.

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC21 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10018/) (material modifiers)
