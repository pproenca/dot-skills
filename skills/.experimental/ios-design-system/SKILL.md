---
name: ios-design-system
description: Airbnb-aligned iOS design system engineering for SwiftUI (iOS 17+) — token architecture, color system engineering, typography scales, spacing tokens, component style libraries with DLS-style protocols, asset management, theming, and governance. Enforces @Equatable on all views, @Observable state, and Airbnb Swift Style Guide naming conventions. This skill should be used when building, organizing, or maintaining a design system for an iOS app, refactoring ad-hoc styles into tokens, creating reusable component styles (ButtonStyle, LabelStyle, custom DLS protocols), structuring asset catalogs, or preventing style drift and duplication.
---

# Airbnb iOS Design System Best Practices

Opinionated, strict design system engineering for SwiftUI iOS 17+ apps. Contains 50 rules across 8 categories, prioritized by impact. Derived from Airbnb's Design Language System (DLS), Airbnb Swift Style Guide, Apple Human Interface Guidelines, and WWDC sessions. Mandates @Equatable on every view, @Observable for state, and style protocols as the primary component API.

## Mandated Architecture Alignment

This skill is designed to work alongside `swift-ui-architect`. All code examples follow the same non-negotiable constraints:

- Feature modules depend on `Domain` + `DesignSystem`; no direct `Data` dependency
- `@Observable` for mutable UI state, `ObservableObject` / `@Published` never
- `@Equatable` macro on every view
- Style protocols as the primary component styling API (Airbnb DLS pattern)
- Asset catalog as the source of truth for color values
- Local SPM package for design system module boundary

## Scope & Relationship to Sibling Skills

This skill is the **infrastructure layer** — it teaches how to BUILD the design system itself. When loaded alongside sibling skills:

| Sibling Skill | Its Focus | This Skill's Focus |
|---------------|-----------|-------------------|
| `swift-ui-architect` | **Architecture** (modular MVVM-C, route shells, protocol boundaries) | **Design system infrastructure** (tokens, styles, governance) |
| `ios-design` | **Using** design primitives (semantic colors, typography) | **Engineering** the token system that provides those primitives |
| `ios-ui-refactor` | **Auditing/fixing** visual quality issues | **Preventing** those issues via governance and automation |
| `ios-hig` | **HIG compliance** patterns | **Asset and component infrastructure** that makes compliance easy |

## When to Apply

Reference these guidelines when:
- Setting up a design system for a new iOS app
- Building token architecture (colors, typography, spacing, sizing)
- Creating reusable component styles (ButtonStyle, LabelStyle, custom DLS protocols)
- Organizing asset catalogs (colors, images, icons)
- Migrating from ad-hoc styles to a governed token system
- Preventing style drift and enforcing consistency via automation
- Building theming infrastructure for whitelabel or multi-brand apps
- Reviewing PRs for ungoverned colors, hardcoded values, or shadow tokens

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Token Architecture | CRITICAL | `token-` | 6 |
| 2 | Color System Engineering | CRITICAL | `color-` | 7 |
| 3 | Component Style Library | CRITICAL | `style-` | 10 |
| 4 | Typography Scale | HIGH | `type-` | 5 |
| 5 | Spacing & Sizing System | HIGH | `space-` | 5 |
| 6 | Consistency & Governance | HIGH | `govern-` | 7 |
| 7 | Asset Management | MEDIUM-HIGH | `asset-` | 5 |
| 8 | Theme & Brand Infrastructure | MEDIUM | `theme-` | 5 |

## Quick Reference

### 1. Token Architecture (CRITICAL)

- [`token-three-layer-hierarchy`](references/token-three-layer-hierarchy.md) - Use Raw → Semantic → Component token layers
- [`token-enum-over-struct`](references/token-enum-over-struct.md) - Use caseless enums for token namespaces
- [`token-single-file-per-domain`](references/token-single-file-per-domain.md) - One token file per design domain
- [`token-shapestyle-extensions`](references/token-shapestyle-extensions.md) - Extend ShapeStyle for dot-syntax colors
- [`token-asset-catalog-source`](references/token-asset-catalog-source.md) - Source color tokens from asset catalog
- [`token-avoid-over-abstraction`](references/token-avoid-over-abstraction.md) - Avoid over-abstracting beyond three layers

### 2. Color System Engineering (CRITICAL)

- [`color-organized-xcassets`](references/color-organized-xcassets.md) - Organize color assets with folder groups by role
- [`color-complete-pairs`](references/color-complete-pairs.md) - Define both appearances for every custom color
- [`color-limit-palette`](references/color-limit-palette.md) - Limit custom colors to under 20 semantic tokens
- [`color-no-hex-in-views`](references/color-no-hex-in-views.md) - Never use Color literals or hex in view code
- [`color-system-first`](references/color-system-first.md) - Prefer system colors before custom tokens
- [`color-tint-not-brand-everywhere`](references/color-tint-not-brand-everywhere.md) - Set brand color as app tint, don't scatter it
- [`color-audit-script`](references/color-audit-script.md) - Audit for ungoverned colors with a build script

### 3. Component Style Library (CRITICAL)

- [`style-dls-protocol-pattern`](references/style-dls-protocol-pattern.md) - Define custom style protocols for complex DLS components
- [`style-equatable-views`](references/style-equatable-views.md) - Apply @Equatable to every design system view
- [`style-accessibility-first`](references/style-accessibility-first.md) - Build accessibility into style protocols, not individual views
- [`style-protocol-over-wrapper`](references/style-protocol-over-wrapper.md) - Use Style protocols instead of wrapper views
- [`style-static-member-syntax`](references/style-static-member-syntax.md) - Provide static member syntax for custom styles
- [`style-environment-awareness`](references/style-environment-awareness.md) - Make styles responsive to environment values
- [`style-view-for-containers-modifier-for-styling`](references/style-view-for-containers-modifier-for-styling.md) - Views for containers, modifiers for styling
- [`style-catalog-file`](references/style-catalog-file.md) - One style catalog file per component type
- [`style-configuration-over-parameters`](references/style-configuration-over-parameters.md) - Prefer configuration structs over many parameters
- [`style-preview-catalog`](references/style-preview-catalog.md) - Create a preview catalog for all styles

### 4. Typography Scale (HIGH)

- [`type-scale-enum`](references/type-scale-enum.md) - Define a type scale enum wrapping system styles
- [`type-system-styles-first`](references/type-system-styles-first.md) - Use system text styles before custom ones
- [`type-custom-font-registration`](references/type-custom-font-registration.md) - Register custom fonts with a centralized extension
- [`type-max-styles-per-screen`](references/type-max-styles-per-screen.md) - Limit typography variations to 3-4 per screen
- [`type-avoid-font-design-mixing`](references/type-avoid-font-design-mixing.md) - Use one font design per app

### 5. Spacing & Sizing System (HIGH)

- [`space-token-enum`](references/space-token-enum.md) - Define spacing tokens as a caseless enum
- [`space-radius-tokens`](references/space-radius-tokens.md) - Define corner radius tokens by component type
- [`space-no-magic-numbers`](references/space-no-magic-numbers.md) - Zero hardcoded numbers in view layout code
- [`space-insets-pattern`](references/space-insets-pattern.md) - Use EdgeInsets constants for composite padding
- [`space-size-tokens`](references/space-size-tokens.md) - Define size tokens for common dimensions

### 6. Consistency & Governance (HIGH)

- [`govern-naming-conventions`](references/govern-naming-conventions.md) - Enforce consistent naming conventions across all tokens
- [`govern-spm-package-boundary`](references/govern-spm-package-boundary.md) - Isolate the design system as a local SPM package
- [`govern-single-source-of-truth`](references/govern-single-source-of-truth.md) - Every visual value has one definition point
- [`govern-lint-for-tokens`](references/govern-lint-for-tokens.md) - Use SwiftLint rules to enforce token usage
- [`govern-design-system-directory`](references/govern-design-system-directory.md) - Isolate tokens in a dedicated directory
- [`govern-migration-incremental`](references/govern-migration-incremental.md) - Migrate to tokens incrementally
- [`govern-prevent-local-tokens`](references/govern-prevent-local-tokens.md) - Prevent feature modules from defining local tokens

### 7. Asset Management (MEDIUM-HIGH)

- [`asset-separate-catalogs`](references/asset-separate-catalogs.md) - Separate asset catalogs for colors, images, icons
- [`asset-sf-symbols-first`](references/asset-sf-symbols-first.md) - Use SF Symbols before custom icons
- [`asset-icon-export-format`](references/asset-icon-export-format.md) - Use PDF/SVG vectors, never multiple PNGs
- [`asset-image-optimization`](references/asset-image-optimization.md) - Use compression and on-demand resources
- [`asset-naming-convention`](references/asset-naming-convention.md) - Consistent naming convention for all assets

### 8. Theme & Brand Infrastructure (MEDIUM)

- [`theme-environment-key`](references/theme-environment-key.md) - Use EnvironmentKey for theme propagation
- [`theme-dont-over-theme`](references/theme-dont-over-theme.md) - Avoid building a theme system unless needed
- [`theme-tint-for-brand`](references/theme-tint-for-brand.md) - Use .tint() as primary brand expression
- [`theme-light-dark-only`](references/theme-light-dark-only.md) - Use ColorScheme for light/dark, not custom theming
- [`theme-brand-layer-separation`](references/theme-brand-layer-separation.md) - Separate brand identity from system mechanics

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
