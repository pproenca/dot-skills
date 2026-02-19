---
title: Isolate the Design System as a Local SPM Package
impact: HIGH
impactDescription: a Swift package boundary enforces token access via explicit import — prevents 100% of accidental direct asset catalog references from feature modules
tags: govern, spm, package, boundary, module
---

## Isolate the Design System as a Local SPM Package

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

A `DesignSystem/` directory inside the app target works until someone in a feature module writes `Color("backgroundPrimary")` directly instead of using the typed `.backgroundPrimary` extension. A local SPM package makes the design system a real module boundary: feature code must `import DesignSystem` to access tokens, and the package's internal types are invisible to consumers. This is the build-system enforcement that directory conventions cannot provide.

**Incorrect (design system as a directory — no module boundary):**

```swift
// Features/Profile/ProfileView.swift
// Developer bypasses typed extensions and uses raw string lookup
Text(user.name)
    .foregroundStyle(Color("textPrimary"))     // Works, but untyped
    .padding(16)                                // Bypasses Spacing tokens
    .background(Color("backgroundSurface"))     // No compile-time check on name
```

**Correct (design system as local SPM package — enforced boundary):**

```text
MyApp/
├── MyApp.xcodeproj
├── Packages/
│   └── DesignSystem/
│       ├── Package.swift
│       ├── Sources/
│       │   └── DesignSystem/
│       │       ├── Tokens/
│       │       │   ├── Colors.swift      // public extensions
│       │       │   ├── Spacing.swift     // public enum
│       │       │   └── Radius.swift      // public enum
│       │       ├── Styles/
│       │       │   └── ButtonStyles.swift // public styles
│       │       └── Internal/
│       │           └── RawTokens.swift   // internal — invisible to consumers
│       └── Resources/
│           └── Colors.xcassets/
└── Sources/
    └── Features/
        └── Profile/
            └── ProfileView.swift         // must: import DesignSystem
```

```swift
// Packages/DesignSystem/Package.swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")]
        ),
    ]
)
```

```swift
// Packages/DesignSystem/Sources/DesignSystem/Tokens/Colors.swift
import SwiftUI

public extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color { Color("backgroundPrimary", bundle: .module) }
    static var textPrimary: Color { Color("textPrimary", bundle: .module) }
    static var accentPrimary: Color { Color("accentPrimary", bundle: .module) }
}
```

```swift
// Features/Profile/ProfileView.swift
import DesignSystem  // Explicit dependency — visible in import section

@Equatable
struct ProfileView: View {
    let user: User

    var body: some View {
        Text(user.name)
            .foregroundStyle(.textPrimary)     // Typed — autocomplete works
            .padding(Spacing.md)                // Typed — globally updatable
            .background(.backgroundSurface)     // Typed — compile-time checked
    }
}
// Color("textPrimary") without bundle: .module resolves to the wrong catalog
```

**Benefits:**
- `internal` access control hides raw tokens from feature code — impossible to bypass the semantic layer
- Explicit `import DesignSystem` makes dependency direction visible in every file
- Package boundary prevents circular dependencies between features and design system
- `bundle: .module` ensures color assets resolve from the package's own catalog

Reference: [Organizing Your Code with Local Packages — Apple Developer](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages)
