---
title: Design App Icons for Distribution
impact: HIGH
impactDescription: creates recognizable, professional app identity
tags: dist, branding, identity, launch, app-icons
---

## Design App Icons for Distribution

Design a simple, recognizable app icon without text or unnecessary detail. Icons should work at all sizes from 1024px down to 29px.

**Incorrect (problematic app icons):**

```text
- Icon with text - unreadable at small sizes
- Photos or screenshots - too complex
- iOS interface elements - confusing context
- Apple product images - trademark violation
- Transparent backgrounds - looks broken
```

**Correct (effective app icons):**

```text
- Simple, distinct silhouette
- Limited color palette (2-3 colors)
- Recognizable at 29px
- Unique within your category
- Consistent with app branding
```

**Icon specifications:**
```text
App Store: 1024x1024px
iPhone: 180x180px (@3x)
iPad: 167x167px (@2x)
Notification: 60x60px
Settings: 87x87px
Spotlight: 120x120px
```

**Design principles:**
- Single focal point
- No text (won't be readable)
- Avoid photos (too detailed)
- Fill the entire space (no margins)
- Works on light and dark wallpapers
- Consider the rounded rect mask

**Providing icons in Xcode:**
```swift
// Asset catalog handles all sizes
// Just provide 1024x1024 in AppIcon asset
// Xcode generates other sizes automatically
```

Reference: [App icons - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
