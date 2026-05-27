---
name: ios-storyboard
description: Legacy interoperability skill for Storyboard and Interface Builder maintenance in iOS 26 / Swift 6.2 clinic codebases. Use only for migration or maintenance of existing storyboard screens; not for new SwiftUI clinic feature development. Triggers on Auto Layout, segues, size classes, IB accessibility, storyboard merge conflicts, and storyboard-to-SwiftUI migration tasks.
---

# iOS Storyboard Best Practices

Legacy interoperability guidance for storyboard-heavy code that still exists in clinic projects. Not for new SwiftUI clinic feature development.

Comprehensive UI design and architecture guide for Xcode Storyboard and Interface Builder, focused on building maintainable, adaptive, and accessible iOS interfaces. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.


## Clinic Architecture Contract (iOS 26 / Swift 6.2)

All guidance in this skill assumes the clinic modular MVVM-C architecture:

- Feature modules import `Domain` + `DesignSystem` only (never `Data`, never sibling features)
- App target is the convergence point and owns `DependencyContainer`, concrete coordinators, and Route Shell wiring
- `Domain` stays pure Swift and defines models plus repository, `*Coordinating`, `ErrorRouting`, and `AppError` contracts
- `Data` owns SwiftData/network/sync/retry/background I/O and implements Domain protocols
- Read/write flow defaults to stale-while-revalidate reads and optimistic queued writes
- ViewModels call repository protocols directly (no default use-case/interactor layer)

## When to Apply

Reference these guidelines when:
- Creating or modifying Storyboard scenes in Xcode Interface Builder
- Setting up Auto Layout constraints for adaptive layouts
- Designing navigation flows with segues and storyboard references
- Configuring size classes and trait variations for universal apps
- Reviewing storyboard XML diffs and resolving merge conflicts

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Storyboard Architecture | CRITICAL | `arch-` |
| 2 | Auto Layout Constraints | CRITICAL | `layout-` |
| 3 | Navigation & Segues | HIGH | `nav-` |
| 4 | Adaptive Layout & Size Classes | HIGH | `adapt-` |
| 5 | View Hierarchy & Stack Views | MEDIUM-HIGH | `view-` |
| 6 | Accessibility & VoiceOver | MEDIUM | `ally-` |
| 7 | Version Control & Collaboration | MEDIUM | `vcs-` |
| 8 | Debugging & Inspection | LOW-MEDIUM | `debug-` |

## Quick Reference

### 1. Storyboard Architecture (CRITICAL)

- [`arch-split-storyboards`](references/arch-split-storyboards.md) - Split Monolithic Storyboards into Feature Modules
- [`arch-storyboard-references`](references/arch-storyboard-references.md) - Use Storyboard References for Cross-Module Navigation
- [`arch-one-scene-per-flow`](references/arch-one-scene-per-flow.md) - Limit Each Storyboard to a Single User Flow
- [`arch-initial-view-controller`](references/arch-initial-view-controller.md) - Set Initial View Controller Explicitly in Every Storyboard
- [`arch-avoid-hardcoded-identifiers`](references/arch-avoid-hardcoded-identifiers.md) - Avoid Hardcoded Storyboard and Cell Identifiers
- [`arch-scene-naming`](references/arch-scene-naming.md) - Use Descriptive Scene Labels in Document Outline
- [`arch-modular-xibs`](references/arch-modular-xibs.md) - Extract Reusable Views into Separate XIB Files

### 2. Auto Layout Constraints (CRITICAL)

- [`layout-avoid-fixed-dimensions`](references/layout-avoid-fixed-dimensions.md) - Avoid Fixed Width and Height Constraints
- [`layout-leading-trailing`](references/layout-leading-trailing.md) - Use Leading and Trailing Instead of Left and Right
- [`layout-safe-area`](references/layout-safe-area.md) - Constrain Views to Safe Area Guides
- [`layout-content-hugging`](references/layout-content-hugging.md) - Set Content Hugging and Compression Resistance Priorities
- [`layout-constraint-nearest-neighbor`](references/layout-constraint-nearest-neighbor.md) - Constrain to Nearest Neighbor Views
- [`layout-avoid-constant-offsets`](references/layout-avoid-constant-offsets.md) - Use Layout Margins Instead of Constant Offsets
- [`layout-inequality-constraints`](references/layout-inequality-constraints.md) - Use Inequality Constraints for Flexible Minimums and Maximums
- [`layout-constraint-priorities`](references/layout-constraint-priorities.md) - Assign Distinct Priorities to Optional Constraints

### 3. Navigation & Segues (HIGH)

- [`nav-prepare-for-segue`](references/nav-prepare-for-segue.md) - Pass Data via prepare(for:sender:) Instead of Direct Property Access
- [`nav-unwind-segues`](references/nav-unwind-segues.md) - Use Unwind Segues to Navigate Backward
- [`nav-avoid-mixed-navigation`](references/nav-avoid-mixed-navigation.md) - Avoid Mixing Segue and Programmatic Navigation
- [`nav-adaptive-segues`](references/nav-adaptive-segues.md) - Use Show and Show Detail Instead of Push and Modal
- [`nav-perform-segue-validation`](references/nav-perform-segue-validation.md) - Validate Segue Conditions with shouldPerformSegue
- [`nav-container-view-controllers`](references/nav-container-view-controllers.md) - Use Container Views for Embedded Child View Controllers

### 4. Adaptive Layout & Size Classes (HIGH)

- [`adapt-size-classes`](references/adapt-size-classes.md) - Configure Constraints per Size Class Using Vary for Traits
- [`adapt-trait-variations`](references/adapt-trait-variations.md) - Use Trait Variations for Font and Spacing Adjustments
- [`adapt-safe-area-all-devices`](references/adapt-safe-area-all-devices.md) - Test Adaptive Layouts on All Device Size Classes
- [`adapt-readable-content-guide`](references/adapt-readable-content-guide.md) - Use Readable Content Guide for Text on Large Screens
- [`adapt-dynamic-type`](references/adapt-dynamic-type.md) - Support Dynamic Type for All Text Labels

### 5. View Hierarchy & Stack Views (MEDIUM-HIGH)

- [`view-prefer-stack-views`](references/view-prefer-stack-views.md) - Use Stack Views Instead of Manual Constraints for Linear Layouts
- [`view-avoid-deep-nesting`](references/view-avoid-deep-nesting.md) - Avoid Deeply Nested Stack Views Beyond Two Levels
- [`view-intrinsic-content-size`](references/view-intrinsic-content-size.md) - Rely on Intrinsic Content Size for Standard UIKit Controls
- [`view-placeholder-intrinsic-size`](references/view-placeholder-intrinsic-size.md) - Use Placeholder Intrinsic Size for Custom Views in Storyboard
- [`view-clip-to-bounds`](references/view-clip-to-bounds.md) - Enable Clip to Bounds for Views with Corner Radius
- [`view-content-mode`](references/view-content-mode.md) - Set Correct Content Mode for UIImageView in Storyboard

### 6. Accessibility & VoiceOver (MEDIUM)

- [`ally-labels`](references/ally-labels.md) - Set Accessibility Labels for All Interactive Elements
- [`ally-traits`](references/ally-traits.md) - Assign Correct Accessibility Traits in Interface Builder
- [`ally-grouping`](references/ally-grouping.md) - Group Related Elements for VoiceOver Navigation
- [`ally-identifiers`](references/ally-identifiers.md) - Set Accessibility Identifiers for UI Testing
- [`ally-dynamic-labels`](references/ally-dynamic-labels.md) - Update Accessibility Labels for Dynamic Content

### 7. Version Control & Collaboration (MEDIUM)

- [`vcs-one-scene-per-developer`](references/vcs-one-scene-per-developer.md) - Assign Storyboard Scenes to Individual Developers
- [`vcs-open-as-source`](references/vcs-open-as-source.md) - Review Storyboard Diffs as Source Code Before Committing
- [`vcs-lock-storyboard-files`](references/vcs-lock-storyboard-files.md) - Use Git File Locking for Active Storyboard Edits
- [`vcs-gitattributes-merge`](references/vcs-gitattributes-merge.md) - Configure .gitattributes to Use Union Merge for Storyboards

### 8. Debugging & Inspection (LOW-MEDIUM)

- [`debug-view-hierarchy`](references/debug-view-hierarchy.md) - Use Debug View Hierarchy to Inspect Layout Issues
- [`debug-ambiguous-layout`](references/debug-ambiguous-layout.md) - Use hasAmbiguousLayout to Detect Constraint Problems at Runtime
- [`debug-constraint-identifier`](references/debug-constraint-identifier.md) - Assign Identifiers to Constraints for Readable Logs
- [`debug-stale-outlets`](references/debug-stale-outlets.md) - Remove Stale Outlet Connections to Prevent Crashes

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
