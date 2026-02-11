---
title: Organize Color Assets with Folder Groups by Role
impact: CRITICAL
impactDescription: structured asset catalogs reduce color discovery time from minutes to seconds and prevent duplicate color definitions
tags: color, xcassets, organization, asset-catalog, folder-structure
---

## Organize Color Assets with Folder Groups by Role

An asset catalog with 30+ color sets at the root level becomes an unscannable wall of names. Developers scroll past colors they need, add duplicates because they cannot find existing ones, and waste time in code review verifying whether a color already exists. Folder groups inside the asset catalog organize colors by semantic role — background, text, border, status, brand — making the catalog self-documenting and navigable.

**Incorrect (flat list of colors at root level):**

```text
Colors.xcassets/
├── accentPrimary.colorset/
├── accentSecondary.colorset/
├── backgroundElevated.colorset/
├── backgroundPrimary.colorset/
├── backgroundSurface.colorset/
├── borderDefault.colorset/
├── borderSubtle.colorset/
├── brandGradientEnd.colorset/
├── brandGradientStart.colorset/
├── brandPrimary.colorset/
├── brandSecondary.colorset/
├── overlayDimmed.colorset/
├── statusError.colorset/
├── statusInfo.colorset/
├── statusSuccess.colorset/
├── statusWarning.colorset/
├── textInverse.colorset/
├── textLink.colorset/
├── textPrimary.colorset/
├── textSecondary.colorset/
└── textTertiary.colorset/
// 20+ items in a flat list — "Is there a borderFocused? Let me scroll through everything..."
```

**Correct (folder groups by semantic role):**

```text
Colors.xcassets/
├── Background/
│   ├── backgroundPrimary.colorset/      // Main app background
│   │   └── Contents.json
│   ├── backgroundSurface.colorset/      // Card/sheet surface
│   │   └── Contents.json
│   └── backgroundElevated.colorset/     // Elevated surface (modal, popover)
│       └── Contents.json
├── Text/
│   ├── textPrimary.colorset/            // Headlines, body text
│   │   └── Contents.json
│   ├── textSecondary.colorset/          // Captions, metadata
│   │   └── Contents.json
│   ├── textTertiary.colorset/           // Placeholders, disabled
│   │   └── Contents.json
│   ├── textInverse.colorset/            // Text on dark backgrounds
│   │   └── Contents.json
│   └── textLink.colorset/              // Tappable text
│       └── Contents.json
├── Border/
│   ├── borderDefault.colorset/          // Standard borders
│   │   └── Contents.json
│   └── borderSubtle.colorset/           // Subtle dividers
│       └── Contents.json
├── Status/
│   ├── statusSuccess.colorset/          // Positive outcomes
│   │   └── Contents.json
│   ├── statusWarning.colorset/          // Caution states
│   │   └── Contents.json
│   ├── statusError.colorset/            // Error states
│   │   └── Contents.json
│   └── statusInfo.colorset/             // Informational states
│       └── Contents.json
├── Brand/
│   ├── accentPrimary.colorset/          // Primary brand / tint
│   │   └── Contents.json
│   ├── accentSecondary.colorset/        // Secondary accent
│   │   └── Contents.json
│   └── brandPrimary.colorset/           // Brand identity color
│       └── Contents.json
└── Overlay/
    └── overlayDimmed.colorset/          // Scrim behind modals
        └── Contents.json
```

**Swift API mirrors the asset catalog structure with MARK comments:**

```swift
// Colors.swift
import SwiftUI

extension ShapeStyle where Self == Color {
    // MARK: - Background
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var backgroundElevated: Color { Color("backgroundElevated") }

    // MARK: - Text
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var textTertiary: Color { Color("textTertiary") }
    static var textInverse: Color { Color("textInverse") }
    static var textLink: Color { Color("textLink") }

    // MARK: - Border
    static var borderDefault: Color { Color("borderDefault") }
    static var borderSubtle: Color { Color("borderSubtle") }

    // MARK: - Status
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusWarning: Color { Color("statusWarning") }
    static var statusError: Color { Color("statusError") }
    static var statusInfo: Color { Color("statusInfo") }

    // MARK: - Brand
    static var accentPrimary: Color { Color("accentPrimary") }
    static var accentSecondary: Color { Color("accentSecondary") }
}
```

**Note on folder groups and Color() initialization:** Folder groups in asset catalogs do NOT affect the string used in `Color("name")`. A color at `Background/backgroundPrimary.colorset` is still referenced as `Color("backgroundPrimary")`, not `Color("Background/backgroundPrimary")`. The folders are purely organizational in Xcode.

**Benefits:**
- Xcode's asset catalog sidebar shows collapsible groups — scan only the category you need
- Duplicate detection is immediate: "Is there already a background color?" — expand the Background folder
- Code review matches: MARK sections in Swift mirror folder groups in the asset catalog
- Adding a new color follows a clear pattern: pick the role folder, create the color set

Reference: [Asset Catalog Format — Apple Developer](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
