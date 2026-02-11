---
title: Provide Static Member Syntax for Custom Styles
impact: HIGH
impactDescription: .buttonStyle(.primary) reads like native SwiftUI — .buttonStyle(PrimaryButtonStyle()) looks like a third-party hack
tags: style, static-member, api-design, discoverability, swiftui
---

## Provide Static Member Syntax for Custom Styles

SwiftUI's built-in styles use dot-syntax: `.bordered`, `.borderedProminent`, `.automatic`, `.plain`. Custom styles should follow the same convention. Without the static member extension, callsites look foreign (`.buttonStyle(PrimaryButtonStyle())`) and lose discoverability — Xcode's autocomplete won't show custom styles when typing `.buttonStyle(.`.

**Incorrect (direct initializer — no dot-syntax):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(.accentPrimary)
            .clipShape(Capsule())
    }
}

// Usage — verbose, doesn't match SwiftUI conventions:
Button("Save") { }
    .buttonStyle(PrimaryButtonStyle())

// Compare with built-in:
Button("Save") { }
    .buttonStyle(.borderedProminent)

// The custom style sticks out as "not native"
```

**Correct (static member extension for dot-syntax):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(.accentPrimary)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}

// Usage — matches SwiftUI convention:
Button("Save") { }
    .buttonStyle(.primary)
```

**Apply this pattern consistently to all style protocols:**

```swift
// ToggleStyle
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(configuration.isOn ? .accentPrimary : .secondary)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { .init() }
}

// LabelStyle
struct SubtitleLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            configuration.title
            configuration.icon
                .foregroundStyle(.secondary)
                .font(AppTypography.caption)
        }
    }
}

extension LabelStyle where Self == SubtitleLabelStyle {
    static var subtitle: SubtitleLabelStyle { .init() }
}

// All read naturally:
Toggle("Notifications", isOn: $notify)
    .toggleStyle(.checkbox)

Label("Settings", systemImage: "gear")
    .labelStyle(.subtitle)
```

**For styles with parameters, use a static method:**

```swift
struct TintedButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(tint)
            .padding(Spacing.sm)
            .background(tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

extension ButtonStyle where Self == TintedButtonStyle {
    static func tinted(_ color: Color) -> TintedButtonStyle {
        .init(tint: color)
    }
}

// Usage:
Button("Warning") { }
    .buttonStyle(.tinted(.orange))
```

Every custom style should have its static member extension defined in the same file, immediately after the style struct.
