---
title: Use Text Renderer for Character-Level Animation (iOS 18)
impact: MEDIUM
impactDescription: enables per-character animation without breaking accessibility — typewriter, wave, and blur effects preserve 100% of text semantics vs. splitting into individual Text views
tags: content, textRenderer, characterLevel, iOS18, advanced
---

## Use Text Renderer for Character-Level Animation (iOS 18)

Standard text animations in SwiftUI operate on the entire `Text` view — it fades in, slides, or scales as a single unit. But some effects require per-character control: typewriter reveals, wave animations where each letter oscillates with a phase offset, or blur-in effects where characters sharpen one at a time. Before iOS 18, achieving this required splitting text into individual `Text` views — which broke accessibility, localization, and text layout.

iOS 18 introduces the `TextRenderer` protocol, which gives you access to individual text runs and glyphs at render time. You implement `draw(layout:in:)` and iterate over lines, runs, and individual glyphs, applying transforms to each. Because this happens at the render layer (not the layout layer), text retains its full accessibility tree, correct line wrapping, and localization support.

**Incorrect (animating entire Text opacity — all-or-nothing reveal):**

```swift
struct WelcomeMessage: View {
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 24) {
            // The entire text fades in as one block.
            // No character-level drama — just a flat fade.
            Text("Welcome back, Sarah")
                .font(.largeTitle.bold())
                .opacity(isVisible ? 1 : 0)
                .animation(.smooth(duration: 0.5), value: isVisible)

            Button("Show") {
                isVisible = true
            }
        }
        .padding()
    }
}
```

**Correct (TextRenderer reveals characters one at a time with a wave effect):**

```swift
struct WaveTextRenderer: TextRenderer {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let totalGlyphs = layout.flatMap { $0 }.reduce(0) { count, run in
            count + run.count
        }
        guard totalGlyphs > 0 else { return }

        var glyphIndex = 0

        for line in layout {
            for run in line {
                for glyph in run {
                    let normalizedIndex = Double(glyphIndex) / Double(totalGlyphs)
                    // Each character reaches full visibility based on progress
                    let characterProgress = max(0, min(1, (progress - normalizedIndex) * Double(totalGlyphs) / 6.0))

                    var copy = context
                    // Vertical wave offset that settles as progress advances
                    let waveOffset = (1 - characterProgress) * -12
                    copy.translateBy(x: 0, y: waveOffset)
                    copy.opacity = characterProgress

                    copy.draw(glyph)

                    glyphIndex += 1
                }
            }
        }
    }
}

@Equatable
struct WelcomeMessage: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Welcome back, Sarah")
                .font(.largeTitle.bold())
                .textRenderer(WaveTextRenderer(progress: progress))

            Button("Animate") {
                progress = 0
                withAnimation(.easeOut(duration: 1.2)) {
                    progress = 1
                }
            }
        }
        .padding()
    }
}
```

**Typewriter effect — characters appear one at a time with a cursor feel:**

```swift
struct TypewriterRenderer: TextRenderer {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let totalGlyphs = layout.flatMap { $0 }.reduce(0) { count, run in
            count + run.count
        }
        guard totalGlyphs > 0 else { return }

        let visibleCount = Int(Double(totalGlyphs) * progress)
        var glyphIndex = 0

        for line in layout {
            for run in line {
                for glyph in run {
                    if glyphIndex < visibleCount {
                        context.draw(glyph)
                    }
                    glyphIndex += 1
                }
            }
        }
    }
}

@Equatable
struct TypewriterDemo: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("The quick brown fox jumps over the lazy dog.")
                .font(.title3)
                .textRenderer(TypewriterRenderer(progress: progress))

            Button("Type") {
                progress = 0
                withAnimation(.linear(duration: 2.0)) {
                    progress = 1
                }
            }
        }
        .padding()
    }
}
```

**When to use TextRenderer vs. simpler alternatives:**

| Effect needed | Approach |
|---------------|----------|
| Fade entire text in/out | `.opacity` + `.animation` |
| Number digit rolling | `.contentTransition(.numericText)` |
| Text morph between two strings | `.contentTransition(.interpolate)` |
| Per-character wave, typewriter, blur | `TextRenderer` (iOS 18+) |

**Key constraints:**
- `TextRenderer` is available starting iOS 18.
- The `draw(layout:in:)` method runs every frame during animation — keep it lightweight.
- Do not perform allocations or complex calculations inside the draw method. Pre-compute values where possible.
- `animatableData` must be declared for SwiftUI to interpolate your progress value.

**Note:** this is an advanced API. For most text animation needs, `.contentTransition(.numericText)` or `.contentTransition(.interpolate)` are simpler and sufficient. Reach for `TextRenderer` only when you need individual glyph control.

Reference: [WWDC 2024 — Create custom visual effects with SwiftUI](https://developer.apple.com/wwdc24/10151)
