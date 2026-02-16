---
title: Create a Preview Catalog for All Design System Styles
impact: HIGH
impactDescription: reduces style regression discovery from weeks (design review) to seconds (preview catalog) — serves as living documentation for 100% of style variants
tags: style, preview, catalog, documentation, xcode
---

## Create a Preview Catalog for All Design System Styles

A preview catalog is a dedicated preview file that renders every style variant in the design system side by side. It serves two purposes: living documentation (any developer can see all available styles instantly) and regression detection (a visual change to any style is immediately visible). Without it, styles are invisible until encountered in feature code, and regressions hide until design review — often weeks later.

**Incorrect (styles only visible in feature context):**

```swift
// The only way to see PrimaryButtonStyle is to navigate to
// CheckoutView's preview. There's no overview of all styles.
// If SecondaryButtonStyle's padding drifts, nobody notices
// until a designer files a bug three sprints later.

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(cart: .mock)
        // Button styles are somewhere in this 500-line view...
    }
}
```

**Correct (dedicated preview catalog with all variants):**

```swift
// DesignSystem/Previews/ButtonStyleCatalog.swift

#Preview("Buttons — Primary Variants") {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            Section("Sizes") {
                VStack(spacing: Spacing.sm) {
                    Button("Small") { }.buttonStyle(.primary).controlSize(.small)
                    Button("Regular") { }.buttonStyle(.primary).controlSize(.regular)
                    Button("Large") { }.buttonStyle(.primary).controlSize(.large)
                }
            }
            Section("States") {
                VStack(spacing: Spacing.sm) {
                    Button("Enabled") { }.buttonStyle(.primary)
                    Button("Disabled") { }.buttonStyle(.primary).disabled(true)
                }
            }
            Section("Content") {
                VStack(spacing: Spacing.sm) {
                    Button("Text Only") { }.buttonStyle(.primary)
                    Button { } label: {
                        Label("With Icon", systemImage: "paperplane.fill")
                    }.buttonStyle(.primary)
                }
            }
        }
        .padding(Spacing.md)
    }
}
```

```swift
#Preview("Buttons — All Styles") {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            ForEach(["Primary", "Secondary", "Outlined", "Destructive"], id: \.self) { style in
                Section(style) { buttonRow(style: style) }
            }
        }
        .padding(Spacing.md)
    }
}
```

**Catalog for other component types:**

```swift
// DesignSystem/Previews/TypographyCatalog.swift

#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: Spacing.md) {
            typographyRow("Display Large", font: AppTypography.displayLarge)
            typographyRow("Display Medium", font: AppTypography.displayMedium)
            typographyRow("Headline Primary", font: AppTypography.headlinePrimary)
            typographyRow("Headline Secondary", font: AppTypography.headlineSecondary)
            typographyRow("Body Primary", font: AppTypography.bodyPrimary)
            typographyRow("Body Secondary", font: AppTypography.bodySecondary)
            typographyRow("Caption", font: AppTypography.caption)
            typographyRow("Caption Secondary", font: AppTypography.captionSecondary)
        }
        .padding(Spacing.md)
    }
}

@ViewBuilder
private func typographyRow(_ name: String, font: Font) -> some View {
    VStack(alignment: .leading, spacing: Spacing.xxs) {
        Text(name)
            .font(font)
        Text(name)
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
}
```

```swift
// DesignSystem/Previews/SpacingCatalog.swift

#Preview("Spacing Tokens") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        spacingRow("xxs", value: Spacing.xxs)
        spacingRow("xs", value: Spacing.xs)
        spacingRow("sm", value: Spacing.sm)
        spacingRow("md", value: Spacing.md)
        spacingRow("lg", value: Spacing.lg)
        spacingRow("xl", value: Spacing.xl)
        spacingRow("xxl", value: Spacing.xxl)
    }
    .padding(Spacing.md)
}

@ViewBuilder
private func spacingRow(_ name: String, value: CGFloat) -> some View {
    HStack(spacing: Spacing.sm) {
        Text("\(name) (\(Int(value))pt)")
            .font(AppTypography.caption)
            .frame(width: 100, alignment: .trailing)

        Rectangle()
            .fill(.accentPrimary)
            .frame(width: value, height: Spacing.md)

        Spacer()
    }
}
```

**Catalog for color tokens:**

```swift
#Preview("Color Tokens") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.sm) {
        colorSwatch("Accent Primary", color: .accentPrimary)
        colorSwatch("Background Surface", color: .backgroundSurface)
        colorSwatch("Text Primary", color: .primary)
        colorSwatch("Text Secondary", color: .secondary)
        // ... all semantic colors
    }
    .padding(Spacing.md)
}

@ViewBuilder
private func colorSwatch(_ name: String, color: Color) -> some View {
    VStack(spacing: Spacing.xs) {
        RoundedRectangle(cornerRadius: Radius.sm)
            .fill(color)
            .frame(height: 60)
        Text(name)
            .font(AppTypography.captionSecondary)
            .multilineTextAlignment(.center)
    }
}
```

Place all catalog previews in a `DesignSystem/Previews/` folder. They cost nothing at build time (previews are debug-only) and save hours of style archaeology.
