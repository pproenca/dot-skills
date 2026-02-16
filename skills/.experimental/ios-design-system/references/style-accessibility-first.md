---
title: Build Accessibility into Style Protocols, Not Individual Views
impact: HIGH
impactDescription: Airbnb's DLS embeds accessibility in component styles — prevents 100% of accessibility regressions when product engineers create new visual variants
tags: style, accessibility, protocol, dynamic-type, airbnb
---

## Build Accessibility into Style Protocols, Not Individual Views

When accessibility behavior (Dynamic Type support, VoiceOver labels, contrast adjustments) is implemented per-view, every new variant risks missing it. Airbnb's DLS approach builds accessibility directly into the base component or style protocol, so every visual variant inherits correct behavior automatically. A ButtonStyle that reads `@Environment(\.dynamicTypeSize)` and adjusts layout ensures every button variant supports Dynamic Type without per-variant code.

**Incorrect (accessibility added per-variant — inconsistent coverage):**

```swift
struct LargeActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(.accentPrimary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
    // Missing: no Dynamic Type adaptation, no minimum contrast check
}

struct CompactButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(.accentPrimary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
    // Also missing accessibility — duplicated omission
}
```

**Correct (accessibility in the base style, variants inherit it):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.controlSize) private var controlSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil)
            .frame(minHeight: HitTarget.minimum)
            .background(isEnabled ? .accentPrimary : .fill.tertiary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }

    private var font: Font {
        switch controlSize {
        case .mini, .small: .subheadline.weight(.semibold)
        case .large, .extraLarge: .title3.weight(.semibold)
        default: .headline
        }
    }

    private var horizontalPadding: CGFloat {
        controlSize == .small ? Spacing.sm : Spacing.lg
    }

    private var verticalPadding: CGFloat {
        controlSize == .small ? Spacing.xs : Spacing.sm
    }
}
```

**Accessibility checklist for design system styles:**

| Requirement | How to Implement |
|-------------|-----------------|
| Dynamic Type | Read `dynamicTypeSize`, expand layout at accessibility sizes |
| Minimum touch target | `frame(minHeight: HitTarget.minimum)` (44pt) |
| Disabled state | Read `isEnabled`, adjust opacity/color |
| Control size | Read `controlSize`, scale padding/font accordingly |
| Reduce Motion | Read `accessibilityReduceMotion`, skip animations |
| High Contrast | Use semantic colors from asset catalog (automatic) |

**Benefits:**
- Product engineers create new styles without worrying about accessibility — it's built in
- Zero accessibility regressions when adding visual variants
- Accessibility Inspector tests pass for every variant because behavior is centralized
- Consistent with Airbnb's DLS pattern of embedding behavior in the component

Reference: [Accessibility — Apple HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility), [WWDC23 — Build accessible apps with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10034/)
