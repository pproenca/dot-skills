---
title: Make Custom Styles Responsive to Environment Values
impact: HIGH
impactDescription: styles that ignore controlSize, isEnabled, and colorScheme look correct in isolation but break in forms, toolbars, and disabled states — context-aware styles adapt automatically
tags: style, environment, controlSize, isEnabled, adaptive
---

## Make Custom Styles Responsive to Environment Values

SwiftUI propagates environment values down the view hierarchy. When a parent sets `.controlSize(.small)` or `.disabled(true)`, built-in styles adapt automatically. Custom styles that ignore these values break the contract — a button that stays full-size inside a compact toolbar, or one that stays fully opaque when disabled. Reading `@Environment` inside styles makes them behave like first-class citizens.

**Incorrect (ignores environment — looks broken in context):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.accentPrimary)
            .clipShape(Capsule())
            // No isEnabled check — stays fully opaque when disabled
            // No controlSize check — same size everywhere
    }
}

// Breaks here:
Button("Submit") { }
    .buttonStyle(.primary)
    .disabled(true) // Still looks tappable — confuses users

// Breaks here too:
ControlGroup {
    Button("Edit") { }.buttonStyle(.primary)
    Button("Share") { }.buttonStyle(.primary)
}
.controlSize(.small) // Buttons are still huge — overflows the toolbar
```

**Correct (reads environment, adapts to context):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(isEnabled ? .accentPrimary : .fill.tertiary)
            .clipShape(Capsule())
            .opacity(opacity(for: configuration))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }

    // MARK: - Adaptive Properties

    private var font: Font {
        switch controlSize {
        case .mini:                  AppTypography.captionSecondary
        case .small:                 AppTypography.caption
        case .large, .extraLarge:    AppTypography.displayMedium
        default:                     AppTypography.headlinePrimary
        }
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:               Spacing.sm
        case .small:              Spacing.sm
        case .large, .extraLarge: Spacing.xl
        default:                  Spacing.lg
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:               Spacing.xs
        case .small:              Spacing.xs
        case .large, .extraLarge: Spacing.md
        default:                  Spacing.sm
        }
    }

    private var isFullWidth: Bool {
        controlSize == .large || controlSize == .extraLarge
    }

    private func opacity(for configuration: Configuration) -> Double {
        if !isEnabled { return 0.4 }
        if configuration.isPressed { return 0.85 }
        return 1.0
    }
}
```

**Key environment values to read in styles:**

```swift
// isEnabled — always read this, at minimum
@Environment(\.isEnabled) private var isEnabled
// Dim the control when disabled. Users must see the difference.

// controlSize — adapt padding and font
@Environment(\.controlSize) private var controlSize
// .mini, .small, .regular, .large, .extraLarge

// colorScheme — only if the asset catalog isn't enough
@Environment(\.colorScheme) private var colorScheme
// Usually unnecessary — define colors in asset catalogs instead

// dynamicTypeSize — for extreme accessibility sizes
@Environment(\.dynamicTypeSize) private var dynamicTypeSize
// Useful for switching from horizontal to vertical layout at .accessibility3+
```

**Testing all states in previews:**

```swift
#Preview("Primary Button — All States") {
    VStack(spacing: Spacing.md) {
        // Control sizes
        ForEach([ControlSize.small, .regular, .large], id: \.self) { size in
            Button("Submit") { }
                .buttonStyle(.primary)
                .controlSize(size)
        }

        // Disabled
        Button("Submit") { }
            .buttonStyle(.primary)
            .disabled(true)

        // Dark mode
        Button("Submit") { }
            .buttonStyle(.primary)
            .preferredColorScheme(.dark)
    }
    .padding()
}
```

At minimum, every custom style must read `isEnabled` and apply reduced opacity or a muted background when disabled. Ignoring this is a usability bug.
