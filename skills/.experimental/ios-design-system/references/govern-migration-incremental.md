---
title: Migrate to Design Tokens Incrementally, Not All at Once
impact: MEDIUM
impactDescription: big-bang design system migrations introduce 500+ line PRs with high regression risk — incremental migration with one token domain per sprint keeps PRs reviewable and risk low
tags: govern, migration, incremental, pragmatism, refactoring
---

## Migrate to Design Tokens Incrementally, Not All at Once

A big-bang migration that replaces all magic values, restructures the color system, adds typography tokens, and creates component styles in a single PR is unreviewable and untestable. If a visual regression slips in, git blame points to a 2,000-line commit. Incremental migration — one token domain per PR — keeps diffs small, regressions traceable, and lets the team build confidence in the system.

**Incorrect (everything in one massive PR):**

```text
PR #247: "Implement Design System" — 2,847 lines changed

- Created DesignSystem/ directory
- Added Colors.xcassets with 45 semantic colors
- Created Color extensions
- Created Spacing enum
- Created Radius enum
- Created Typography tokens
- Created ButtonStyles
- Created TextFieldStyles
- Replaced all Color(hex:) calls (127 files)
- Replaced all magic paddings (89 files)
- Replaced all Font.system(size:) calls (64 files)
- Added SwiftLint rules
- Fixed 23 layout issues caused by spacing changes

Reviewer: "I can't review this. LGTM, I guess?"
```

**Correct (phased migration, one domain per PR):**

```swift
// PHASE 1 (Sprint 1): Colors — highest visual impact, easiest to verify
// PR #247: "Add semantic color tokens" — 180 lines

// 1a. Create Colors.xcassets with semantic color sets
// 1b. Create Color extensions (ShapeStyle for dot-syntax)
extension ShapeStyle where Self == Color {
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var labelPrimary: Color { Color("labelPrimary") }
    static var accentPrimary: Color { Color("accentPrimary") }
    // ... all semantic colors
}

// 1c. Replace all Color(hex:) and Color(red:green:blue:) calls
// Before:
Text(title).foregroundStyle(Color(hex: "#1C1C1E"))
// After:
Text(title).foregroundStyle(.labelPrimary)

// Verification: visual screenshot comparison, zero layout changes expected
```

```swift
// PHASE 2 (Sprint 2): Spacing — moderate visual impact
// PR #263: "Add spacing tokens" — 120 lines

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// Replace magic padding/spacing values
// Before:
VStack(spacing: 8) { ... }.padding(16)
// After:
VStack(spacing: Spacing.sm) { ... }.padding(Spacing.md)

// Verification: most replacements are 1:1, but audit for edge cases
// where .padding(14) was intentionally different from the scale
```

```swift
// PHASE 3 (Sprint 3): Corner radii
// PR #278: "Add radius tokens" — 60 lines

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = .infinity
}

// Before:
.clipShape(RoundedRectangle(cornerRadius: 12))
// After:
.clipShape(RoundedRectangle(cornerRadius: Radius.md))
```

```swift
// PHASE 4 (Sprint 4): Typography — only if custom type scale needed
// PR #291: "Add typography tokens" — 90 lines
// Most apps should use system text styles (.headline, .body, .caption)
// Only add this phase if the brand requires custom font families or sizes
```

```swift
// PHASE 5 (Sprint 5): Component styles
// PR #305: "Add shared button and text field styles" — 100 lines

struct PrimaryButtonStyle: ButtonStyle { ... }
struct SecondaryButtonStyle: ButtonStyle { ... }
struct BrandedTextFieldStyle: TextFieldStyle { ... }
```

```swift
// PHASE 6 (Sprint 6): Enforcement
// PR #319: "Add SwiftLint rules for token compliance" — 40 lines
// Only enable enforcement AFTER the migration is complete
// Otherwise every existing file triggers warnings
```

**Migration tracking template:**

| Phase | Domain | Files Changed | PR | Status |
|-------|--------|---------------|-----|--------|
| 1 | Colors | ~130 | #247 | Merged |
| 2 | Spacing | ~90 | #263 | In Review |
| 3 | Radii | ~40 | — | Next Sprint |
| 4 | Typography | ~60 | — | Backlog |
| 5 | Component Styles | ~30 | — | Backlog |
| 6 | Lint Enforcement | 1 | — | After Phase 5 |

Each phase produces a reviewable PR (under 200 lines), has a clear verification method (visual diff for colors, layout diff for spacing), and can be rolled back independently if issues arise.
