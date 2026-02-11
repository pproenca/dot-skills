---
title: Isolate All Token Definitions in a Dedicated Directory
impact: MEDIUM
impactDescription: tokens scattered across feature modules are invisible to auditing tools and new developers — a dedicated DesignSystem/ directory makes the system boundary explicit
tags: govern, directory, organization, boundary, discoverability
---

## Isolate All Token Definitions in a Dedicated Directory

When color extensions live in `Views/ProfileView.swift`, spacing constants in `Utils/Constants.swift`, and button styles in `Components/Buttons.swift`, no one can answer "what tokens exist?" without searching the entire codebase. A dedicated `DesignSystem/` directory (or Swift package) creates a clear boundary: everything inside defines the system, everything outside consumes it.

**Incorrect (tokens scattered across the codebase):**

```text
Sources/
├── Utils/
│   ├── Constants.swift           // Spacing values live here
│   └── Extensions/
│       └── Color+Hex.swift       // Color extensions here
├── Views/
│   ├── ProfileView.swift         // Contains local Color("brandTeal")
│   └── Components/
│       ├── PrimaryButton.swift   // Contains ButtonStyle + hardcoded colors
│       └── Card.swift            // Contains local cornerRadius constant
├── Styles/
│   └── TextStyles.swift          // Typography definitions somewhere else
└── Resources/
    └── Assets.xcassets/          // Asset catalog disconnected from code tokens
```

```swift
// Constants.swift — generic dumping ground
enum Constants {
    static let defaultPadding: CGFloat = 16
    static let apiBaseURL = "https://api.example.com"  // Mixed concerns
    static let maxRetries = 3
    static let cardCornerRadius: CGFloat = 12
}
```

**Correct (dedicated DesignSystem directory with clear internal structure):**

```text
Sources/
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift          // Color extensions for asset catalog access
│   │   ├── Spacing.swift         // Spacing scale
│   │   ├── Radius.swift          // Corner radius scale
│   │   └── Typography.swift      // Type scale (if extending beyond system styles)
│   ├── Styles/
│   │   ├── ButtonStyles.swift    // PrimaryButtonStyle, SecondaryButtonStyle
│   │   ├── TextFieldStyles.swift // BrandedTextFieldStyle
│   │   └── ToggleStyles.swift    // Custom toggle styles
│   ├── Components/
│   │   ├── LoadingIndicator.swift // Branded loading spinner
│   │   └── EmptyStateView.swift   // Reusable empty state component
│   └── Extensions/
│       └── View+DesignSystem.swift // Design system view modifiers
├── Features/
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── ProfileViewModel.swift
│   ├── Orders/
│   │   ├── OrderListView.swift
│   │   └── OrderDetailView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Networking/
│   └── APIClient.swift
└── Resources/
    ├── Colors.xcassets/           // Color assets
    ├── Images.xcassets/           // Image assets
    └── Icons.xcassets/            // Icon assets
```

```swift
// DesignSystem/Tokens/Colors.swift — all color tokens in one file
import SwiftUI

extension ShapeStyle where Self == Color {
    // MARK: - Background
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var backgroundElevated: Color { Color("backgroundElevated") }

    // MARK: - Accent
    static var accentPrimary: Color { Color("accentPrimary") }
    static var accentSecondary: Color { Color("accentSecondary") }

    // MARK: - Status
    static var statusSuccess: Color { Color("statusSuccess") }
    static var statusWarning: Color { Color("statusWarning") }
    static var statusError: Color { Color("statusError") }
}

// DesignSystem/Tokens/Spacing.swift — all spacing tokens in one file
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// DesignSystem/Styles/ButtonStyles.swift — all button styles in one file
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
```

**For larger apps, consider a Swift package:**

```text
MyApp.xcodeproj
Packages/
└── DesignSystem/
    ├── Package.swift
    └── Sources/
        └── DesignSystem/
            ├── Tokens/
            ├── Styles/
            └── Components/
```

A Swift package enforces the boundary at the build system level — feature modules must explicitly `import DesignSystem`, making the dependency direction visible and preventing circular references.
