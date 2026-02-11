---
title: One Token File Per Design Domain
impact: CRITICAL
impactDescription: reduces merge conflicts by 80% and makes token discovery instant for any team member
tags: token, file-organization, design-system, maintainability
---

## One Token File Per Design Domain

When all design tokens live in a single file, every color change conflicts with every spacing change in version control. When tokens are scattered across feature files, nobody can find the canonical value. The solution is one file per design domain: colors, typography, spacing, radii, elevation. Each file is small enough to read in 30 seconds, focused enough to avoid merge conflicts, and discoverable enough that new team members find what they need on their first search.

**Incorrect (monolithic file with everything):**

```swift
// DesignSystem.swift — 400+ lines, constant merge conflicts
import SwiftUI

struct DesignSystem {
    // Colors
    static let primaryText = Color(hex: "#1A1A2E")
    static let secondaryText = Color(hex: "#8E8E93")
    static let background = Color(hex: "#F2F2F7")
    // ... 30 more colors

    // Spacing
    static let spacingSm: CGFloat = 8
    static let spacingMd: CGFloat = 16
    // ... 8 more spacing values

    // Typography
    static let titleFont = Font.system(size: 28, weight: .bold)
    static let bodyFont = Font.system(size: 17, weight: .regular)
    // ... 10 more fonts

    // Radii
    static let radiusSm: CGFloat = 4
    static let radiusMd: CGFloat = 8
    // ... 5 more radii
}
```

**Also incorrect (tokens scattered across features):**

```swift
// Features/Profile/ProfileView.swift
private let profileCardRadius: CGFloat = 12
private let profilePadding: CGFloat = 16

// Features/Feed/FeedView.swift
private let feedCardRadius: CGFloat = 12  // Duplicate, might drift
private let feedPadding: CGFloat = 16     // Same value, no single source
```

**Correct (one file per design domain):**

```text
DesignSystem/
├── Package.swift            // Local SPM package for the design system
├── Sources/
│   ├── Colors.swift         // ShapeStyle extensions, ~40 lines
│   ├── Typography.swift     // Font extensions, ~30 lines
│   ├── Spacing.swift        // Spacing enum, ~15 lines
│   ├── Radius.swift         // Corner radius enum, ~12 lines
│   ├── Elevation.swift      // Shadow definitions, ~20 lines
│   └── Animation.swift      // Duration and spring constants, ~15 lines
└── Resources/
    └── Colors.xcassets/     // Color asset catalog
```

```swift
// DesignSystem/Sources/Colors.swift
import SwiftUI

extension ShapeStyle where Self == Color {
    // MARK: - Backgrounds
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var backgroundElevated: Color { Color("backgroundElevated") }

    // MARK: - Text
    static var textPrimary: Color { Color("textPrimary") }
    static var textSecondary: Color { Color("textSecondary") }
    static var textTertiary: Color { Color("textTertiary") }

    // MARK: - Status
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusWarning: Color { Color("statusWarning") }
    static var statusError: Color { Color("statusError") }

    // MARK: - Brand
    static var accentPrimary: Color { Color("accentPrimary") }
}
```

```swift
// DesignSystem/Sources/Spacing.swift
import SwiftUI

enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

```swift
// DesignSystem/Sources/Typography.swift
import SwiftUI

extension Font {
    static var displayLarge: Font { .system(.largeTitle, weight: .bold) }
    static var displayMedium: Font { .system(.title, weight: .semibold) }
    static var titleStandard: Font { .system(.title3, weight: .semibold) }
    static var bodyStandard: Font { .system(.body) }
    static var bodySecondary: Font { .system(.subheadline) }
    static var captionStandard: Font { .system(.caption) }
}
```

```swift
// DesignSystem/Sources/Radius.swift
import SwiftUI

enum Radius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999
}
```

**Benefits:**
- Merge conflicts are isolated to the domain being changed — a color update never conflicts with a spacing PR
- Cmd+Shift+O in Xcode: type "Spacing" and go directly to the file
- Each file fits on a single screen, making audits trivial
- New team members learn the system in minutes by scanning 5-6 small files

Reference: [Modular Design Systems](https://developer.apple.com/documentation/swiftui/model-data), [SPM Local Packages](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages)
