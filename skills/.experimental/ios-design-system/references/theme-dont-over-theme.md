---
title: Avoid Building a Theme System Unless You Need Multiple Themes
impact: MEDIUM
impactDescription: premature theme infrastructure adds 200-500 lines of code that most apps never use — asset catalog + .tint() covers 90% of branding needs
tags: theme, pragmatism, over-engineering, yagni
---

## Avoid Building a Theme System Unless You Need Multiple Themes

Most iOS apps have exactly one visual identity. They don't need a `ThemeProvider`, a `ThemeManager`, or a `ThemeRepository`. The asset catalog with Any/Dark appearance variants IS the theme. The `.tint()` modifier IS the brand expression. Building theme switching infrastructure for an app that will only ever have one look is over-engineering that adds indirection without value.

**Incorrect (unnecessary theme infrastructure for a single-brand app):**

```swift
// 200+ lines of infrastructure for one visual identity

protocol ThemeProtocol {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var cornerRadius: CGFloat { get }
    var spacing: SpacingTheme { get }
    var typography: TypographyTheme { get }
}

struct DefaultTheme: ThemeProtocol {
    let primaryColor = Color("brandBlue")
    let secondaryColor = Color("brandTeal")
    // ... 15 more properties, all mapping to the same asset catalog values
}

@Observable
class ThemeManager {
    var current: ThemeProtocol = DefaultTheme()

    func switchTheme(_ theme: ThemeProtocol) {  // Never called
        current = theme
    }
}

struct ThemeProvider<Content: View>: View {
    @State private var themeManager = ThemeManager()
    let content: () -> Content

    var body: some View {
        content()
            .environment(themeManager)
    }
}

// Every view now depends on ThemeManager for colors that never change
struct ProfileCard: View {
    @Environment(ThemeManager.self) var themeManager

    var body: some View {
        content
            .background(themeManager.current.surfaceColor)  // Indirection for no reason
    }
}
```

**Correct (asset catalog + semantic extensions + .tint() for single-brand apps):**

```swift
// The asset catalog IS the theme. Extensions provide type-safe access.

// DesignSystem/Tokens/Colors.swift
extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var accentPrimary: Color { Color("accentPrimary") }
    static var labelPrimary: Color { Color("labelPrimary") }
}

// App entry point — one line of brand expression
@main
struct RecipeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(.accentPrimary)
        }
    }
}

// Views use semantic colors directly — no indirection layer
@Equatable
struct ProfileCard: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(user.displayName)
                .font(.headline)
            Text(user.bio)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.md)
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
```

**When you DO need a theme system:**

| Scenario | Theme System Needed? |
|----------|---------------------|
| Single brand, light/dark mode | No — asset catalog handles it |
| Single brand, custom accent color picker | Use `.tint()` with a stored color — no full theme system needed |
| Whitelabel app (multiple client brands) | Yes |
| User-selectable themes (like Telegram) | Yes |
| A/B testing different visual treatments | Yes |

The rule is simple: if you can count your themes on zero fingers, you don't need theme infrastructure.
