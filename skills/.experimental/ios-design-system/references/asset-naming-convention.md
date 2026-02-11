---
title: Use Consistent Naming Convention for All Assets
impact: MEDIUM-HIGH
impactDescription: inconsistent asset names ("bg_home", "homeBackground", "HomeBG") make discovery impossible — consistent naming eliminates the #1 cause of accidental duplicate assets
tags: asset, naming, convention, consistency, discovery
---

## Use Consistent Naming Convention for All Assets

When three developers name the same background color `bg_home`, `homeBackground`, and `HomeBG`, you get three assets that do the same thing. Consistent naming is the cheapest governance tool in a design system — it makes duplicates obvious, autocomplete useful, and audit scripts trivial to write.

**Incorrect (mixed naming conventions across asset types):**

```text
Assets.xcassets/
├── bg_home.colorset/            // snake_case
├── homeBackground.colorset/     // camelCase
├── HomeBG.colorset/             // PascalCase abbreviation
├── hero-image-home.imageset/    // kebab-case with type prefix
├── imgHero.imageset/            // camelCase with type abbreviation
├── ic_back.imageset/            // Android-style snake_case
├── close-icon.imageset/         // type suffix instead of prefix
└── CloseBtn.imageset/           // PascalCase abbreviation
```

**Correct (structured naming by asset type):**

```text
Colors.xcassets/
├── Background/
│   ├── backgroundPrimary.colorset/       // camelCase, semantic role
│   ├── backgroundSecondary.colorset/
│   ├── backgroundSurface.colorset/
│   └── backgroundElevated.colorset/
├── Label/
│   ├── labelPrimary.colorset/
│   ├── labelSecondary.colorset/
│   └── labelTertiary.colorset/
├── Fill/
│   ├── fillPrimary.colorset/
│   └── fillQuaternary.colorset/
├── Separator/
│   └── separatorOpaque.colorset/
└── Accent/
    ├── accentPrimary.colorset/
    └── accentSecondary.colorset/

Images.xcassets/
├── Illustrations/
│   ├── onboarding-welcome.imageset/      // kebab-case, context-first
│   ├── onboarding-complete.imageset/
│   └── empty-state-no-results.imageset/
├── Backgrounds/
│   ├── gradient-hero-home.imageset/
│   └── gradient-hero-profile.imageset/
└── Photos/
    └── placeholder-avatar.imageset/

Icons.xcassets/
├── Navigation/
│   ├── icon-arrow-back.imageset/         // kebab-case, prefixed
│   ├── icon-close.imageset/
│   └── icon-menu.imageset/
└── Brand/
    ├── icon-brand-logo.imageset/
    └── icon-brand-wordmark.imageset/
```

```swift
// Swift extensions mirror the naming convention exactly
extension ShapeStyle where Self == Color {
    // Background
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }

    // Label
    static var labelPrimary: Color { Color("labelPrimary") }
    static var labelSecondary: Color { Color("labelSecondary") }
}

extension Image {
    // Illustrations — match asset catalog name exactly
    static let onboardingWelcome = Image("onboarding-welcome")
    static let emptyStateNoResults = Image("empty-state-no-results")
}
```

**Naming rules summary:**

| Asset Type | Case | Pattern | Example |
|------------|------|---------|---------|
| Colors | camelCase | `{role}{Variant}` | `backgroundPrimary` |
| Images | kebab-case | `{context}-{descriptor}` | `onboarding-welcome` |
| Icons | kebab-case | `icon-{descriptor}` | `icon-arrow-back` |
| Folders | PascalCase | `{Category}` | `Background/`, `Navigation/` |

The key principle: color names match Swift property conventions (camelCase), image/icon names use kebab-case for readability in the asset catalog sidebar where they appear as plain strings.
