---
name: tailwind-refactor
description: Tailwind CSS code refactoring patterns for v4 migration and anti-pattern cleanup. This skill should be used when refactoring Tailwind utility classes, migrating from v3 to v4, cleaning up deprecated utilities, consolidating verbose class patterns, or removing code smells — all without changing the visual output. Triggers on tasks involving Tailwind CSS cleanup, v4 migration, class refactoring, @apply removal, or utility modernization.
---

# Community Tailwind CSS Refactoring Best Practices

Comprehensive code quality refactoring guide for Tailwind CSS applications targeting v4. Contains 47 rules across 8 categories, prioritized by migration urgency. Every transformation preserves the existing look and feel — this skill is purely about cleaner code, modern syntax, and v4 compatibility.

**Companion skills:** Use [tailwind-ui-refactor](../tailwind-ui-refactor/) for visual design improvements and [tailwind-responsive-ui](../tailwind-responsive-ui/) for responsive layout patterns.

## When to Apply

Reference these guidelines when:
- Migrating a project from Tailwind CSS v3 to v4
- Cleaning up deprecated or renamed utility classes
- Consolidating verbose multi-class patterns
- Replacing arbitrary values with design tokens
- Removing `@apply` overuse in CSS files
- Modernizing syntax to v4 conventions

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Configuration Migration | CRITICAL | `config-` |
| 2 | Deprecated Utility Replacement | CRITICAL | `dep-` |
| 3 | Renamed Utility Updates | HIGH | `rename-` |
| 4 | Class Consolidation | HIGH | `class-` |
| 5 | Arbitrary Value Cleanup | MEDIUM-HIGH | `arb-` |
| 6 | Syntax Modernization | MEDIUM | `syntax-` |
| 7 | @apply & Architecture Cleanup | MEDIUM | `arch-` |
| 8 | Modern Feature Adoption | LOW-MEDIUM | `adopt-` |

## Quick Reference

### 1. Configuration Migration (CRITICAL)

- [`config-import-directive`](references/config-import-directive.md) - Replace @tailwind directives with @import
- [`config-css-theme`](references/config-css-theme.md) - Migrate tailwind.config.js to CSS @theme
- [`config-theme-function`](references/config-theme-function.md) - Replace theme() function with CSS variables
- [`config-utility-directive`](references/config-utility-directive.md) - Replace @layer utilities with @utility
- [`config-postcss-plugin`](references/config-postcss-plugin.md) - Update PostCSS plugin to @tailwindcss/postcss
- [`config-content-autodetect`](references/config-content-autodetect.md) - Remove manual content configuration
- [`config-custom-variant`](references/config-custom-variant.md) - Migrate addVariant to @custom-variant

### 2. Deprecated Utility Replacement (CRITICAL)

- [`dep-opacity-modifiers`](references/dep-opacity-modifiers.md) - Replace *-opacity-* with opacity modifiers (/50)
- [`dep-flex-shorthand`](references/dep-flex-shorthand.md) - Replace flex-shrink/flex-grow with shrink/grow
- [`dep-text-ellipsis`](references/dep-text-ellipsis.md) - Replace overflow-ellipsis with text-ellipsis
- [`dep-decoration-utilities`](references/dep-decoration-utilities.md) - Replace decoration-slice/clone with box-decoration-*
- [`dep-transform-composites`](references/dep-transform-composites.md) - Replace transform-none with individual resets
- [`dep-transition-properties`](references/dep-transition-properties.md) - Update transition-[transform] to individual properties

### 3. Renamed Utility Updates (HIGH)

- [`rename-shadow-scale`](references/rename-shadow-scale.md) - Update shadow utilities to new scale
- [`rename-blur-scale`](references/rename-blur-scale.md) - Update blur utilities to new scale
- [`rename-rounded-scale`](references/rename-rounded-scale.md) - Update border radius utilities to new scale
- [`rename-ring-width`](references/rename-ring-width.md) - Replace ring with ring-3 for v3 default
- [`rename-gradient-utilities`](references/rename-gradient-utilities.md) - Replace bg-gradient-* with bg-linear-*
- [`rename-outline-hidden`](references/rename-outline-hidden.md) - Replace outline-none with outline-hidden

### 4. Class Consolidation (HIGH)

- [`class-size-utility`](references/class-size-utility.md) - Replace matching w-* h-* with size-*
- [`class-gap-over-space`](references/class-gap-over-space.md) - Prefer gap-* over space-x/y-* in flex/grid
- [`class-inset-shorthand`](references/class-inset-shorthand.md) - Replace top/right/bottom/left with inset-*
- [`class-border-color-explicit`](references/class-border-color-explicit.md) - Add explicit border color for v4 default change
- [`class-redundant-display`](references/class-redundant-display.md) - Remove redundant display classes
- [`class-hidden-priority`](references/class-hidden-priority.md) - Remove display overrides for hidden attribute
- [`class-container-utility`](references/class-container-utility.md) - Replace container plugin config with @utility

### 5. Arbitrary Value Cleanup (MEDIUM-HIGH)

- [`arb-hex-to-theme`](references/arb-hex-to-theme.md) - Replace arbitrary hex colors with theme tokens
- [`arb-spacing-to-scale`](references/arb-spacing-to-scale.md) - Replace arbitrary spacing with theme scale
- [`arb-dynamic-classes`](references/arb-dynamic-classes.md) - Avoid dynamic class name construction
- [`arb-breakpoint-to-theme`](references/arb-breakpoint-to-theme.md) - Replace arbitrary breakpoints with @theme
- [`arb-zindex-to-scale`](references/arb-zindex-to-scale.md) - Replace arbitrary z-index with theme scale

### 6. Syntax Modernization (MEDIUM)

- [`syntax-css-variable-parens`](references/syntax-css-variable-parens.md) - Update CSS variable syntax from brackets to parentheses
- [`syntax-variant-stacking`](references/syntax-variant-stacking.md) - Update variant stacking to left-to-right order
- [`syntax-important-modifier`](references/syntax-important-modifier.md) - Use trailing ! for important modifier
- [`syntax-grid-arbitrary`](references/syntax-grid-arbitrary.md) - Use underscores in grid arbitrary values
- [`syntax-gradient-preservation`](references/syntax-gradient-preservation.md) - Reset gradient stops explicitly in variants
- [`syntax-hover-media-query`](references/syntax-hover-media-query.md) - Account for hover variant media query wrapping

### 7. @apply & Architecture Cleanup (MEDIUM)

- [`arch-apply-to-component`](references/arch-apply-to-component.md) - Extract @apply blocks into framework components
- [`arch-layer-to-utility`](references/arch-layer-to-utility.md) - Replace @layer components with @utility
- [`arch-scoped-reference`](references/arch-scoped-reference.md) - Use @reference for @apply in scoped styles
- [`arch-safelist-to-source`](references/arch-safelist-to-source.md) - Replace safelist with @source inline()
- [`arch-domain-composition`](references/arch-domain-composition.md) - Reserve Tailwind for primitives, compose for domain

### 8. Modern Feature Adoption (LOW-MEDIUM)

- [`adopt-container-queries`](references/adopt-container-queries.md) - Use container queries instead of viewport breakpoints
- [`adopt-not-variant`](references/adopt-not-variant.md) - Use not-* variant for negated conditions
- [`adopt-in-variant`](references/adopt-in-variant.md) - Use in-* variant instead of group class
- [`adopt-field-sizing`](references/adopt-field-sizing.md) - Use field-sizing-content for auto-resizing textareas
- [`adopt-starting-variant`](references/adopt-starting-variant.md) - Use starting variant for entry animations without JS

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
