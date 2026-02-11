---
name: ios-ui-refactor
description: Principal-level iOS UI review and refactoring patterns for SwiftUI. Evaluates visual hierarchy, typography, color systems, motion, transitions, materials, spacing, and iOS 17+ modernization. This skill should be used when reviewing, auditing, or refactoring existing SwiftUI views, screens, transitions, animations, or color usage to reach Apple-quality design standards while preserving the app's brand identity.
---

# Apple HIG SwiftUI iOS 17+ Best Practices

A principal designer's lens for evaluating and refactoring SwiftUI interfaces to Apple-quality standards. Contains 48 rules across 8 categories, ordered by the visual review process a senior Apple designer follows when auditing an app. Each rule identifies a specific anti-pattern, explains why it degrades the experience, and provides the iOS 17+ fix while respecting the app's brand voice.

## Scope & Relationship to Sibling Skills

This skill is the **refactoring and review lens** — it evaluates existing UI and identifies visual anti-patterns to fix. When loaded alongside `ios-design` (building new UI), `ios-hig` (HIG compliance), or `swift-refactor` (code-level refactoring), this skill supersedes overlapping rules with more detailed "incorrect → correct" transformations and "When NOT to apply" guidance. Use this skill for auditing and improving existing screens; use the siblings for greenfield implementation.

## When to Apply

Reference these guidelines when:
- Reviewing existing SwiftUI screens for visual quality issues
- Auditing typography scale, weight usage, and type treatments
- Evaluating color system coherence across light and dark mode
- Refactoring animations from legacy easeInOut to spring-based motion
- Fixing navigation transitions that break spatial continuity
- Replacing custom overlays with Apple's materials system
- Standardizing spacing, touch targets, and corner radii
- Adopting iOS 17-18 APIs like scrollTransition, PhaseAnimator, or MeshGradient

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Visual Hierarchy | CRITICAL | `hier-` |
| 2 | Typography Discipline | CRITICAL | `typo-` |
| 3 | Color System | CRITICAL | `color-` |
| 4 | Motion & Animation | HIGH | `motion-` |
| 5 | Screen Transitions | HIGH | `trans-` |
| 6 | Materials & Depth | HIGH | `depth-` |
| 7 | Spacing & Rhythm | MEDIUM-HIGH | `rhythm-` |
| 8 | iOS 17+ Modernization | MEDIUM | `modern-` |

## Quick Reference

### 1. Visual Hierarchy (CRITICAL)

- [`hier-single-focal`](references/hier-single-focal.md) - One primary focal point per screen
- [`hier-size-weight-contrast`](references/hier-size-weight-contrast.md) - Combine size, weight, and contrast for hierarchy
- [`hier-progressive-disclosure`](references/hier-progressive-disclosure.md) - Use progressive disclosure for dense information
- [`hier-card-modularity`](references/hier-card-modularity.md) - Use self-contained cards for dashboard layouts
- [`hier-whitespace-grouping`](references/hier-whitespace-grouping.md) - Use whitespace to separate conceptual groups
- [`hier-reading-order`](references/hier-reading-order.md) - Align visual weight with logical reading order

### 2. Typography Discipline (CRITICAL)

- [`typo-system-text-styles`](references/typo-system-text-styles.md) - Use Apple text styles, never fixed font sizes
- [`typo-weight-not-caps`](references/typo-weight-not-caps.md) - Use weight for emphasis, not ALL CAPS
- [`typo-single-typeface`](references/typo-single-typeface.md) - One typeface per app, differentiate with weight and size
- [`typo-max-styles-per-screen`](references/typo-max-styles-per-screen.md) - Limit to 3-4 distinct type treatments per screen
- [`typo-no-light-body`](references/typo-no-light-body.md) - Avoid light font weights for body text
- [`typo-foreground-style`](references/typo-foreground-style.md) - Use foregroundStyle over foregroundColor

### 3. Color System (CRITICAL)

- [`color-semantic-always`](references/color-semantic-always.md) - Use semantic colors, never hard-coded black or white
- [`color-role-naming`](references/color-role-naming.md) - Name custom colors by role, not hue
- [`color-contrast-aa`](references/color-contrast-aa.md) - Ensure WCAG AA contrast ratios
- [`color-saturated-small`](references/color-saturated-small.md) - Reserve saturated colors for small interactive elements
- [`color-dark-mode-pairs`](references/color-dark-mode-pairs.md) - Define light and dark variants for every custom color
- [`color-brand-within-system`](references/color-brand-within-system.md) - Map brand palette onto iOS semantic color roles
- [`color-one-purpose`](references/color-one-purpose.md) - Each semantic color serves exactly one purpose

### 4. Motion & Animation (HIGH)

- [`motion-spring-default`](references/motion-spring-default.md) - Default to spring animations for all UI transitions
- [`motion-spring-presets`](references/motion-spring-presets.md) - Use .smooth for routine, .snappy for interactive, .bouncy for delight
- [`motion-no-linear-easeInOut`](references/motion-no-linear-easeInOut.md) - Prefer springs over linear and easeInOut for UI elements
- [`motion-symbol-effects`](references/motion-symbol-effects.md) - Use built-in symbolEffect, not manual symbol animation
- [`motion-content-transition`](references/motion-content-transition.md) - Use contentTransition for changing text and numbers
- [`motion-reduce-motion`](references/motion-reduce-motion.md) - Always provide reduce motion fallback
- [`motion-purposeful`](references/motion-purposeful.md) - Every animation must communicate state change or provide feedback

### 5. Screen Transitions (HIGH)

- [`trans-zoom-collections`](references/trans-zoom-collections.md) - Use zoom transitions for collection-to-detail navigation
- [`trans-sheet-vs-push`](references/trans-sheet-vs-push.md) - Sheets for tasks and creation, push for drill-down hierarchy
- [`trans-multi-detent-sheets`](references/trans-multi-detent-sheets.md) - Provide multiple sheet detents with drag indicator
- [`trans-matched-geometry`](references/trans-matched-geometry.md) - Use matchedGeometryEffect for contextual origin transitions
- [`trans-no-hard-cuts`](references/trans-no-hard-cuts.md) - Always animate between states, even minimally
- [`trans-preserve-swipe-back`](references/trans-preserve-swipe-back.md) - Never break the system back-swipe gesture

### 6. Materials & Depth (HIGH)

- [`depth-materials-not-opacity`](references/depth-materials-not-opacity.md) - Use system materials, not custom semi-transparent backgrounds
- [`depth-vibrancy-hierarchy`](references/depth-vibrancy-hierarchy.md) - Match vibrancy level to content importance
- [`depth-material-thickness`](references/depth-material-thickness.md) - Choose material thickness by contrast needs
- [`depth-background-interaction`](references/depth-background-interaction.md) - Enable background interaction for peek-style sheets
- [`depth-shadow-vs-material`](references/depth-shadow-vs-material.md) - Use materials for layering, not drop shadows for depth

### 7. Spacing & Rhythm (MEDIUM-HIGH)

- [`rhythm-consistent-grid`](references/rhythm-consistent-grid.md) - Use a 4pt base unit for all spacing
- [`rhythm-touch-targets`](references/rhythm-touch-targets.md) - All interactive elements at least 44x44 points
- [`rhythm-consistent-radii`](references/rhythm-consistent-radii.md) - Standardize corner radii per component type
- [`rhythm-consistent-padding`](references/rhythm-consistent-padding.md) - Use consistent padding across all screens
- [`rhythm-alignment-consistency`](references/rhythm-alignment-consistency.md) - Consistent alignment per content type within a screen
- [`rhythm-safe-area-respect`](references/rhythm-safe-area-respect.md) - Always respect safe areas

### 8. iOS 17+ Modernization (MEDIUM)

- [`modern-scroll-transitions`](references/modern-scroll-transitions.md) - Use scrollTransition for scroll-position visual effects
- [`modern-phase-animator`](references/modern-phase-animator.md) - Use PhaseAnimator for multi-step animation sequences
- [`modern-mesh-gradients`](references/modern-mesh-gradients.md) - Use MeshGradient for premium dynamic backgrounds
- [`modern-text-renderer`](references/modern-text-renderer.md) - Use TextRenderer for hero text animations only
- [`modern-inspector`](references/modern-inspector.md) - Use inspector for trailing-edge detail panels

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
