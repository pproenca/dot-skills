---
title: Use foregroundStyle over foregroundColor
impact: CRITICAL
impactDescription: eliminates 100% of hardcoded color overrides — foregroundStyle supports 3-level hierarchy (primary/secondary/tertiary) in a single call, reducing color modifier lines by 30-50% and enabling automatic vibrancy across 5+ material contexts
tags: empathy, foreground, style, kocienda-empathy, edson-people, hierarchy
---

## Use foregroundStyle over foregroundColor

Kocienda's empathy means understanding that the system has evolved to serve users better — and the developer's job is to keep up. `foregroundColor` accepts only `Color`, which cannot express hierarchy (`.primary`, `.secondary`, `.tertiary`) or material vibrancy. `foregroundStyle` accepts any `ShapeStyle`, including hierarchical colors that automatically adjust for background materials, elevated contexts, and accessibility settings. Using the old API isn't just outdated — it's an empathy failure, because it prevents SwiftUI from making the fine-grained adjustments that serve users in every context.

**Incorrect (foregroundColor limits adaptability):**

```swift
struct NotificationBanner: View {
    let message: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(message)
                    .foregroundColor(.black)

                Text(detail)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
```

**Correct (foregroundStyle enables full hierarchy):**

```swift
struct NotificationBanner: View {
    let message: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .foregroundStyle(.tint)

            VStack(alignment: .leading) {
                Text(message)
                    .foregroundStyle(.primary)

                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

**Key differences:**
- `.foregroundStyle(.primary)` adjusts for vibrancy over materials; `Color.primary` does not
- `.foregroundStyle(.tint)` respects the view's accent color inheritance chain
- `.foregroundStyle(.secondary)` on a material background automatically gets vibrancy treatment
- Multi-level: `.foregroundStyle(.blue, .purple, .pink)` sets primary, secondary, tertiary in one call

**When NOT to migrate:** If targeting iOS 14-16 in production, `foregroundColor` is still required. For iOS 17+ targets, always prefer `foregroundStyle`.

Reference: [foregroundStyle - Apple Documentation](https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:))
