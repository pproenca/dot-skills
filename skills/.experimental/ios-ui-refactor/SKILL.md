---
name: ios-ui-refactor
description: Principal-level SwiftUI UI review and refactoring patterns for iOS 26 / Swift 6.2 clinic-architecture apps, grounded in Rams, Segall, and Edson principles. Use when auditing or improving existing SwiftUI screens, transitions, animations, and visual systems while preserving brand identity and respecting clinic Domain/Data/App boundaries.
---

# Apple HIG SwiftUI iOS 26 / Swift 6.2 Best Practices

A principal designer's lens for evaluating and refactoring SwiftUI interfaces to Apple-quality standards, grounded in Rams, Segall, and Edson. Contains 51 rules across 8 categories, each grounded in specific principles from three foundational design texts:

- **Dieter Rams** — *Ten Principles for Good Design* ("less, but better," "design should be honest")
- **Ken Segall** — *Insanely Simple* (simplicity as a core principle for intuitive, beautiful products)
- **John Edson** — *Design Like Apple* (design-focused culture, prototyping to perfection, the product is the marketing)

Categories are ordered by a visual review process: start with what to remove, then what to clarify, then what to make honest, invisible, systematic, thorough, enduring, and finally what to refine.

## Scope & Relationship to Sibling Skills

This skill is the **refactoring and review lens** — it evaluates existing UI and identifies visual anti-patterns to fix. When loaded alongside `ios-design` (building new UI), `ios-hig` (HIG compliance), or `swift-refactor` (code-level refactoring), this skill supersedes overlapping rules with more detailed "incorrect -> correct" transformations and "When NOT to apply" guidance. Use this skill for auditing and improving existing screens; use the siblings for greenfield implementation.


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
- Reviewing existing SwiftUI screens for visual quality issues
- Auditing whether every element on screen earns its place (Rams #10)
- Evaluating if the interface is self-explanatory without tooltips (Rams #4)
- Checking that colors, states, and hierarchy tell the truth (Rams #6)
- Ensuring animations and materials are invisible, not decorative (Rams #5)
- Verifying spacing, radii, and colors form a coherent system (Edson "Systems Thinking")
- Confirming edge cases — reduce motion, touch targets, safe areas — are handled (Rams #8)
- Adopting iOS 26 / Swift 6.2 APIs that refine previously impossible interactions (Edson "Design Out Loud")

## Rule Categories by Priority

| Priority | Category | Principle | Impact | Prefix | Rules |
|----------|----------|-----------|--------|--------|-------|
| 1 | Less, But Better | Rams #10 + Segall "Think Minimal" | CRITICAL | `less-` | 7 |
| 2 | Self-Evident Design | Rams #4 + Segall "Think Human" | CRITICAL | `evident-` | 6 |
| 3 | Honest Interfaces | Rams #6 + Segall "Think Brutal" | CRITICAL | `honest-` | 6 |
| 4 | Invisible Design | Rams #5 + Edson "Product Is Marketing" | HIGH | `invisible-` | 6 |
| 5 | Systems, Not Pieces | Edson "Systems Thinking" + Rams #8 | HIGH | `system-` | 6 |
| 6 | Thorough to the Last Detail | Rams #8 + Rams #2 | HIGH | `thorough-` | 7 |
| 7 | Enduring Over Trendy | Rams #7 + Edson "Design With Conviction" | MEDIUM-HIGH | `enduring-` | 5 |
| 8 | Refined Through Iteration | Edson "Design Out Loud" + Rams #1/#3 | MEDIUM | `refined-` | 8 |

## Quick Reference

### 1. Less, But Better (CRITICAL)

Rams #10: "Good design is as little design as possible." Segall: Apple succeeded by saying no to a thousand things.

- [`less-single-focal`](references/less-single-focal.md) - One primary focal point per screen
- [`less-type-restraint`](references/less-type-restraint.md) - Limit to 3-4 distinct type treatments per screen
- [`less-one-typeface`](references/less-one-typeface.md) - One typeface per app, differentiate with weight and size
- [`less-color-restraint`](references/less-color-restraint.md) - Reserve saturated colors for small interactive elements
- [`less-one-color-purpose`](references/less-one-color-purpose.md) - Each semantic color serves exactly one purpose
- [`less-purposeful-motion`](references/less-purposeful-motion.md) - Every animation must communicate state change or provide feedback
- [`less-fewer-controls`](references/less-fewer-controls.md) - Remove controls that do not serve the core task

### 2. Self-Evident Design (CRITICAL)

Rams #4: "Good design makes a product understandable." Segall: interfaces must speak in terms people understand.

- [`evident-visual-weight`](references/evident-visual-weight.md) - Combine size, weight, and contrast for hierarchy
- [`evident-whitespace-grouping`](references/evident-whitespace-grouping.md) - Use whitespace to separate conceptual groups
- [`evident-progressive-disclosure`](references/evident-progressive-disclosure.md) - Use progressive disclosure for dense information
- [`evident-reading-order`](references/evident-reading-order.md) - Align visual weight with logical reading order
- [`evident-navigation-intent`](references/evident-navigation-intent.md) - Sheets for tasks and creation, push for drill-down hierarchy
- [`evident-label-clarity`](references/evident-label-clarity.md) - Use clear labels over ambiguous icons

### 3. Honest Interfaces (CRITICAL)

Rams #6: "Good design is honest." Segall: clarity without sugar-coating.

- [`honest-semantic-colors`](references/honest-semantic-colors.md) - Use semantic colors, never hard-coded black or white
- [`honest-contrast`](references/honest-contrast.md) - Ensure WCAG AA contrast ratios
- [`honest-dark-mode`](references/honest-dark-mode.md) - Define light and dark variants for every custom color
- [`honest-foreground-style`](references/honest-foreground-style.md) - Use foregroundStyle over foregroundColor
- [`honest-depth-cues`](references/honest-depth-cues.md) - Use materials for layering, not drop shadows for depth
- [`honest-loading-states`](references/honest-loading-states.md) - Show real progress, not indefinite spinners

### 4. Invisible Design (HIGH)

Rams #5: "Good design is unobtrusive." Edson: the product itself is the marketing.

- [`invisible-spring-physics`](references/invisible-spring-physics.md) - Default to spring animations for all UI transitions
- [`invisible-spring-presets`](references/invisible-spring-presets.md) - Use .smooth for routine, .snappy for interactive, .bouncy for delight
- [`invisible-no-easing`](references/invisible-no-easing.md) - Prefer springs over linear and easeInOut for UI elements
- [`invisible-system-materials`](references/invisible-system-materials.md) - Use system materials, not custom semi-transparent backgrounds
- [`invisible-symbol-effects`](references/invisible-symbol-effects.md) - Use built-in symbolEffect, not manual symbol animation
- [`invisible-content-transitions`](references/invisible-content-transitions.md) - Use contentTransition for changing text and numbers

### 5. Systems, Not Pieces (HIGH)

Edson: "Design is systems thinking." Rams #8: nothing must be arbitrary or left to chance.

- [`system-spacing-grid`](references/system-spacing-grid.md) - Use a 4pt base unit for all spacing
- [`system-consistent-padding`](references/system-consistent-padding.md) - Use consistent padding across all screens
- [`system-corner-radii`](references/system-corner-radii.md) - Standardize corner radii per component type
- [`system-alignment`](references/system-alignment.md) - Consistent alignment per content type within a screen
- [`system-color-naming`](references/system-color-naming.md) - Name custom colors by role, not hue
- [`system-brand-integration`](references/system-brand-integration.md) - Map brand palette onto iOS semantic color roles

### 6. Thorough to the Last Detail (HIGH)

Rams #8: "Care and accuracy in the design process show respect for the user." Rams #2: if the user cannot reliably use it, the product has failed.

- [`thorough-reduce-motion`](references/thorough-reduce-motion.md) - Always provide reduce motion fallback
- [`thorough-touch-targets`](references/thorough-touch-targets.md) - All interactive elements at least 44x44 points
- [`thorough-safe-areas`](references/thorough-safe-areas.md) - Always respect safe areas
- [`thorough-readable-weights`](references/thorough-readable-weights.md) - Avoid light font weights for body text
- [`thorough-vibrancy-levels`](references/thorough-vibrancy-levels.md) - Match vibrancy level to content importance
- [`thorough-material-thickness`](references/thorough-material-thickness.md) - Choose material thickness by contrast needs
- [`thorough-background-interaction`](references/thorough-background-interaction.md) - Enable background interaction for peek-style sheets

### 7. Enduring Over Trendy (MEDIUM-HIGH)

Rams #7: "Good design is long-lasting." Edson: commit to a voice that persists across product generations.

- [`enduring-system-text-styles`](references/enduring-system-text-styles.md) - Use Apple text styles, never fixed font sizes
- [`enduring-weight-not-caps`](references/enduring-weight-not-caps.md) - Use weight for emphasis, not ALL CAPS
- [`enduring-swipe-back`](references/enduring-swipe-back.md) - Never break the system back-swipe gesture
- [`enduring-zoom-navigation`](references/enduring-zoom-navigation.md) - Use zoom transitions for collection-to-detail navigation
- [`enduring-card-modularity`](references/enduring-card-modularity.md) - Use self-contained cards for dashboard layouts

### 8. Refined Through Iteration (MEDIUM)

Edson: "Design out loud" — prototype relentlessly until every interaction feels inevitable. Rams #1: innovation serves genuine purpose.

- [`refined-scroll-transitions`](references/refined-scroll-transitions.md) - Use scrollTransition for scroll-position visual effects
- [`refined-phase-animator`](references/refined-phase-animator.md) - Use PhaseAnimator for multi-step animation sequences
- [`refined-mesh-gradients`](references/refined-mesh-gradients.md) - Use MeshGradient for premium dynamic backgrounds
- [`refined-text-renderer`](references/refined-text-renderer.md) - Use TextRenderer for hero text animations only
- [`refined-inspector`](references/refined-inspector.md) - Use inspector for trailing-edge detail panels
- [`refined-multi-detent`](references/refined-multi-detent.md) - Provide multiple sheet detents with drag indicator
- [`refined-matched-geometry`](references/refined-matched-geometry.md) - Use matchedGeometryEffect for contextual origin transitions
- [`refined-no-hard-cuts`](references/refined-no-hard-cuts.md) - Always animate between states, even minimally

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure, principle sources, and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and principle grounding |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
