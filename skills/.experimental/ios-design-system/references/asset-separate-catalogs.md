---
title: Use Separate Asset Catalogs for Colors, Images, and Icons
impact: MEDIUM-HIGH
impactDescription: a single Assets.xcassets with 200+ items is unsearchable — separate catalogs reduce Xcode navigation time by 5x and prevent accidental overwrites
tags: asset, xcassets, organization, separation, catalog
---

## Use Separate Asset Catalogs for Colors, Images, and Icons

A monolithic Assets.xcassets becomes unmanageable past 50 items. Xcode's sidebar has no search within catalogs, so finding `backgroundTertiary` among 200 mixed assets means scrolling. Separate catalogs also reduce merge conflicts — color changes never conflict with image additions.

**Incorrect (everything in one catalog):**

```text
MyApp/
└── Assets.xcassets/
    ├── AccentColor.colorset/
    ├── AppIcon.appiconset/
    ├── backgroundPrimary.colorset/
    ├── backgroundSurface.colorset/
    ├── brandLogo.imageset/
    ├── hero-onboarding.imageset/
    ├── icon-back.imageset/
    ├── icon-close.imageset/
    ├── labelPrimary.colorset/
    ├── labelSecondary.colorset/
    ├── onboarding-step1.imageset/
    ├── separatorOpaque.colorset/
    └── ... (180 more items)
```

**Correct (purpose-specific catalogs with folder groups):**

```text
MyApp/Resources/
├── Assets.xcassets/              // App icon + accent color only
│   ├── AccentColor.colorset/
│   └── AppIcon.appiconset/
├── Colors.xcassets/              // All semantic colors
│   ├── Background/
│   │   ├── backgroundPrimary.colorset/
│   │   ├── backgroundSecondary.colorset/
│   │   └── backgroundSurface.colorset/
│   ├── Label/
│   │   ├── labelPrimary.colorset/
│   │   └── labelSecondary.colorset/
│   └── Separator/
│       └── separatorOpaque.colorset/
├── Images.xcassets/              // Photos, illustrations, backgrounds
│   ├── Illustrations/
│   │   ├── onboarding-welcome.imageset/
│   │   └── onboarding-complete.imageset/
│   └── Marketing/
│       └── hero-homepage.imageset/
└── Icons.xcassets/               // Custom icons (non-SF-Symbol)
    ├── Navigation/
    │   ├── icon-back.imageset/
    │   └── icon-close.imageset/
    └── Brand/
        └── brand-logo.imageset/
```

All catalogs in the same target are accessible via `Color("backgroundPrimary")` or `Image("brand-logo")` regardless of which `.xcassets` file they live in. The separation is purely organizational — zero runtime cost.
