---
title: Use ColorScheme for Light/Dark Switching, Not Custom Theming
impact: MEDIUM
impactDescription: the asset catalog's Any/Dark appearance system is the canonical way to handle light and dark mode — building a custom light/dark theme duplicates what iOS provides for free
tags: theme, light-dark, colorScheme, asset-catalog, simplicity
---

## Use ColorScheme for Light/Dark Switching, Not Custom Theming

Light and dark mode are not "themes" — they are system-level appearance variants that iOS handles automatically through the asset catalog. Every color set in Xcassets supports Any Appearance and Dark Appearance slots. When the user toggles dark mode in Control Center, every `Color("tokenName")` resolves to the correct variant with zero code. Building custom `LightTheme`/`DarkTheme` structs duplicates this built-in mechanism.

**Incorrect (custom theme structs for light/dark switching):**

```swift
// Unnecessary abstraction over a system feature
struct LightTheme: ThemeColors {
    let background = Color(hex: "#FFFFFF")
    let surface = Color(hex: "#F5F5F5")
    let labelPrimary = Color(hex: "#1C1C1E")
    let labelSecondary = Color(hex: "#8E8E93")
    let separator = Color(hex: "#C6C6C8")
}

struct DarkTheme: ThemeColors {
    let background = Color(hex: "#000000")
    let surface = Color(hex: "#1C1C1E")
    let labelPrimary = Color(hex: "#FFFFFF")
    let labelSecondary = Color(hex: "#8E8E93")
    let separator = Color(hex: "#38383A")
}

class ThemeManager: ObservableObject {
    @Published var colors: ThemeColors

    init() {
        // Manually tracking what the system already tracks
        colors = UITraitCollection.current.userInterfaceStyle == .dark
            ? DarkTheme()
            : LightTheme()
    }

    func updateForColorScheme(_ scheme: ColorScheme) {
        colors = scheme == .dark ? DarkTheme() : LightTheme()
    }
}

// Every view depends on ThemeManager instead of using asset catalog colors
struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            Text("Account")
                .foregroundColor(themeManager.colors.labelPrimary)
        }
        .background(themeManager.colors.background)
    }
}
```

**Correct (asset catalog Any/Dark variants, no custom theme layer):**

```text
Colors.xcassets/
└── backgroundPrimary.colorset/
    └── Contents.json
```

```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.949", "green": "0.949", "blue": "0.969", "alpha": "1.000" }
      },
      "idiom": "universal"
    },
    {
      "appearances": [
        { "appearance": "luminosity", "value": "dark" }
      ],
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.000", "green": "0.000", "blue": "0.000", "alpha": "1.000" }
      },
      "idiom": "universal"
    }
  ]
}
```

```swift
// Views use semantic colors — light/dark switching is automatic
struct SettingsView: View {
    var body: some View {
        List {
            Text("Account")
                .foregroundStyle(.labelPrimary)  // Adapts automatically
        }
        .background(.backgroundPrimary)          // Adapts automatically
    }
}

// To force a specific appearance on a subtree:
struct AlwaysDarkPlayer: View {
    var body: some View {
        VideoPlayer(url: videoURL)
            .preferredColorScheme(.dark)  // This subtree is always dark
    }
}

// To let users override system appearance in-app:
@main
struct MyApp: App {
    @AppStorage("appearanceOverride") var appearanceOverride = 0  // 0=system, 1=light, 2=dark

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(
                    appearanceOverride == 0 ? nil :
                    appearanceOverride == 1 ? .light : .dark
                )
        }
    }
}
```

The asset catalog + `.preferredColorScheme()` covers every light/dark scenario. Reserve custom theme systems for genuinely distinct visual identities (whitelabel, user-selectable color themes), not for appearance mode switching.
