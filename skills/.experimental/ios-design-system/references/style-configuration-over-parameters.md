---
title: Prefer Configuration Structs Over Many Style Parameters
impact: HIGH
impactDescription: a style with 5+ parameters becomes unwieldy — a configuration struct groups related properties and provides sensible defaults
tags: style, configuration, api-design, parameters, maintainability
---

## Prefer Configuration Structs Over Many Style Parameters

When a component style evolves past 2-3 parameters, each new parameter multiplies the combinatorial complexity of the API. A style with 5 booleans has 32 possible states — most of them untested. Configuration structs solve this by grouping related properties, providing sensible defaults, and enabling named presets. This follows Apple's own pattern where `ButtonStyleConfiguration` and `ToggleStyleConfiguration` bundle properties into a single value.

**Incorrect (too many parameters — hard to read and maintain):**

```swift
struct CustomButtonStyle: ButtonStyle {
    var fontSize: CGFloat = 16
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 12
    var cornerRadius: CGFloat = 12
    var isFullWidth: Bool = false
    var hasShadow: Bool = false
    var shadowRadius: CGFloat = 4
    var hapticFeedback: Bool = true
    var iconPosition: IconPosition = .leading

    enum IconPosition { case leading, trailing }

    func makeBody(configuration: Configuration) -> some View {
        // ... complex body using all 9 parameters
    }
}

// Callsite — hard to read, easy to misconfigure:
Button("Submit") { }
    .buttonStyle(CustomButtonStyle(
        fontSize: 18,
        horizontalPadding: 32,
        verticalPadding: 16,
        cornerRadius: 24,
        isFullWidth: true,
        hasShadow: true,
        shadowRadius: 8,
        hapticFeedback: true,
        iconPosition: .trailing
    ))
// What does this combination even look like?
```

**Correct (configuration struct with defaults and presets):**

```swift
// Configuration groups related properties
struct AppButtonConfiguration {
    var size: ControlSize = .regular
    var isFullWidth: Bool = false
    var haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .light

    // Named presets for common combinations
    static let compact = AppButtonConfiguration(size: .small)
    static let fullWidth = AppButtonConfiguration(isFullWidth: true)
    static let hero = AppButtonConfiguration(size: .large, isFullWidth: true, haptic: .medium)
    static let quiet = AppButtonConfiguration(haptic: nil)
}

struct PrimaryButtonStyle: ButtonStyle {
    var config: AppButtonConfiguration = .init()

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: config.isFullWidth ? .infinity : nil)
            .background(isEnabled ? .accentPrimary : .fill.tertiary)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed, let style = config.haptic {
                    UIImpactFeedbackGenerator(style: style).impactOccurred()
                }
            }
    }

    private var font: Font {
        switch config.size {
        case .small: AppTypography.caption
        case .large, .extraLarge: AppTypography.displayMedium
        default: AppTypography.headlinePrimary
        }
    }

    private var horizontalPadding: CGFloat {
        switch config.size {
        case .small: Spacing.sm
        case .large, .extraLarge: Spacing.xl
        default: Spacing.lg
        }
    }

    private var verticalPadding: CGFloat {
        switch config.size {
        case .small: Spacing.xs
        case .large, .extraLarge: Spacing.md
        default: Spacing.sm
        }
    }
}

// Static members use presets:
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }

    static var primaryCompact: PrimaryButtonStyle {
        .init(config: .compact)
    }

    static var primaryHero: PrimaryButtonStyle {
        .init(config: .hero)
    }
}
```

**Clean callsites:**

```swift
// Default — most common case, zero configuration
Button("Save") { }
    .buttonStyle(.primary)

// Preset — named configuration, self-documenting
Button("Get Started") { }
    .buttonStyle(.primaryHero)

// Custom — rare, but possible when needed
Button("Apply Filter") { }
    .buttonStyle(PrimaryButtonStyle(config: .init(
        isFullWidth: true,
        haptic: nil
    )))
```

**When to use configuration vs separate styles:**

```swift
// Use CONFIGURATION when variations share 80%+ of their rendering logic:
// PrimaryButtonStyle with config: .compact vs .hero vs .fullWidth
// Same structure, different sizing

// Use SEPARATE STYLES when the rendering logic fundamentally differs:
// PrimaryButtonStyle (filled) vs OutlinedButtonStyle (stroked) vs GhostButtonStyle (text-only)
// Different backgrounds, different shapes — separate styles
```

Configuration structs keep the number of style types small (3-5 per component) while still offering flexibility. If you find yourself creating `PrimarySmallButtonStyle`, `PrimaryLargeButtonStyle`, `PrimaryFullWidthButtonStyle` — consolidate them into one style with a configuration.
