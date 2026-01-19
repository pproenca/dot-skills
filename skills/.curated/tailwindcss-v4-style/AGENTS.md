# Tailwind CSS v4

**Version 0.1.0**  
Tailwind Labs  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization and best practices guide for Tailwind CSS v4, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (build configuration, CSS generation) to incremental (animation patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Build Configuration](references/_sections.md#1-build-configuration) — **CRITICAL**
   - 1.1 [Leverage Automatic Content Detection](references/build-content-detection.md) — CRITICAL (eliminates manual configuration, prevents missing utilities)
   - 1.2 [Remove Redundant PostCSS Plugins](references/build-postcss-simplify.md) — HIGH (reduces plugin overhead, simplifies configuration)
   - 1.3 [Use Correct CLI Package](references/build-cli-package.md) — HIGH (prevents build failures, ensures v4 compatibility)
   - 1.4 [Use CSS Import Over @tailwind Directives](references/build-css-import.md) — CRITICAL (eliminates deprecated patterns, enables v4 features)
   - 1.5 [Use Node.js 20+ for Optimal Performance](references/build-node-version.md) — CRITICAL (required for upgrade tool, enables modern optimizations)
   - 1.6 [Use Vite Plugin Over PostCSS](references/build-vite-plugin.md) — CRITICAL (3-10× faster incremental builds)
2. [CSS Generation](references/_sections.md#2-css-generation) — **CRITICAL**
   - 2.1 [Avoid Excessive Theme Variables](references/gen-avoid-theme-bloat.md) — CRITICAL (reduces CSS variable overhead by 50-80%)
   - 2.2 [Use @utility for Custom Utilities](references/gen-utility-directive.md) — HIGH (enables variant support, proper sorting)
   - 2.3 [Use CSS-First Configuration Over JavaScript](references/gen-css-first-config.md) — CRITICAL (single source of truth, eliminates config file overhead)
   - 2.4 [Use Dynamic Utility Values](references/gen-dynamic-utilities.md) — HIGH (eliminates arbitrary value syntax, cleaner markup)
   - 2.5 [Use OKLCH Color Space for Vivid Colors](references/gen-oklch-colors.md) — HIGH (20-30% wider color gamut, perceptually uniform)
   - 2.6 [Use Parentheses for CSS Variable References](references/gen-css-variable-syntax.md) — MEDIUM-HIGH (required v4 syntax, prevents build errors)
3. [Bundle Optimization](references/_sections.md#3-bundle-optimization) — **HIGH**
   - 3.1 [Avoid Play CDN in Production](references/bundle-avoid-cdn-production.md) — HIGH (10-100× larger payload, runtime compilation overhead)
   - 3.2 [Avoid Sass/Less Preprocessors](references/bundle-avoid-preprocessors.md) — HIGH (prevents compatibility issues, enables native features)
   - 3.3 [Enable CSS Minification in Production](references/bundle-css-minification.md) — HIGH (40-60% smaller CSS bundles)
   - 3.4 [Extract Critical CSS for Initial Render](references/bundle-split-critical-css.md) — MEDIUM-HIGH (100-300ms faster FCP on slow connections)
   - 3.5 [Remove Built-in Plugins](references/bundle-remove-unused-plugins.md) — HIGH (eliminates duplicate code, reduces dependencies)
4. [Utility Patterns](references/_sections.md#4-utility-patterns) — **HIGH**
   - 4.1 [Use Explicit Border and Ring Colors](references/util-explicit-colors.md) — HIGH (prevents invisible borders, ensures consistent appearance)
   - 4.2 [Use Left-to-Right Variant Stacking](references/util-variant-stacking.md) — HIGH (prevents broken responsive/state styles)
   - 4.3 [Use Renamed Utility Classes](references/util-renamed-utilities.md) — HIGH (prevents broken styles, ensures v4 compatibility)
   - 4.4 [Use Slash Opacity Modifier](references/util-opacity-modifier.md) — HIGH (50% fewer opacity-related classes)
   - 4.5 [Use Trailing Important Modifier](references/util-important-modifier.md) — HIGH (prevents v4 syntax errors)
   - 4.6 [Use via-none to Reset Gradient Stops](references/util-gradient-via-none.md) — MEDIUM-HIGH (prevents unexpected gradient behavior with variants)
5. [Component Architecture](references/_sections.md#5-component-architecture) — **MEDIUM-HIGH**
   - 5.1 [Avoid Overusing @apply](references/comp-avoid-apply-overuse.md) — MEDIUM-HIGH (prevents CSS bloat, maintains utility-first benefits)
   - 5.2 [Customize Container with @utility](references/comp-container-customize.md) — MEDIUM (prevents v4 migration breakage)
   - 5.3 [Leverage Smart Utility Sorting](references/comp-smart-sorting.md) — MEDIUM (automatic cascade ordering, fewer specificity issues)
   - 5.4 [Understand Utility File Scope](references/comp-utility-file-scope.md) — MEDIUM-HIGH (prevents build errors and missing class bugs)
   - 5.5 [Use @reference for CSS Module Integration](references/comp-reference-directive.md) — MEDIUM-HIGH (eliminates duplicate CSS output in modules)
6. [Theming & Design Tokens](references/_sections.md#6-theming-&-design-tokens) — **MEDIUM**
   - 6.1 [Leverage Runtime CSS Variables](references/theme-runtime-variables.md) — MEDIUM (enables dynamic theming without JavaScript)
   - 6.2 [Set color-scheme for Native Dark Mode](references/theme-color-scheme.md) — MEDIUM (eliminates visual theme inconsistencies)
   - 6.3 [Use Class-Based Dark Mode for Control](references/theme-dark-mode-class.md) — MEDIUM (enables manual theme switching, better user control)
   - 6.4 [Use Prefix for Variable Namespacing](references/theme-prefix-variables.md) — MEDIUM (prevents CSS variable conflicts in large codebases)
   - 6.5 [Use Semantic Design Token Names](references/theme-semantic-tokens.md) — MEDIUM (improves maintainability, enables theme switching)
7. [Responsive & Adaptive](references/_sections.md#7-responsive-&-adaptive) — **MEDIUM**
   - 7.1 [Define Custom Breakpoints in @theme](references/resp-custom-breakpoints.md) — MEDIUM (enables project-specific responsive design)
   - 7.2 [Understand Hover Behavior on Touch Devices](references/resp-hover-capability.md) — MEDIUM (prevents sticky hover states on mobile)
   - 7.3 [Use Container Queries for Component-Level Responsiveness](references/resp-container-queries.md) — MEDIUM (eliminates viewport-dependent component bugs)
   - 7.4 [Use Logical Properties for RTL Support](references/resp-logical-properties.md) — MEDIUM (automatic RTL support without duplicate styles)
   - 7.5 [Use Mobile-First Responsive Design](references/resp-mobile-first.md) — MEDIUM (10-30% smaller CSS output)
8. [Animation & Transitions](references/_sections.md#8-animation-&-transitions) — **LOW-MEDIUM**
   - 8.1 [Use @starting-style for Entry Animations](references/anim-starting-style.md) — LOW-MEDIUM (enables CSS-only entry animations, no JavaScript)
   - 8.2 [Use Built-in 3D Transform Utilities](references/anim-3d-transforms.md) — LOW-MEDIUM (enables 3D effects without custom CSS)
   - 8.3 [Use GPU-Accelerated Transform Properties](references/anim-gpu-accelerated.md) — LOW-MEDIUM (60fps animations, avoids layout thrashing)
   - 8.4 [Use OKLCH Gradient Interpolation](references/anim-gradient-interpolation.md) — LOW-MEDIUM (20-40% more vivid gradient midpoints)

---

## References

1. [https://tailwindcss.com/docs](https://tailwindcss.com/docs)
2. [https://tailwindcss.com/blog/tailwindcss-v4](https://tailwindcss.com/blog/tailwindcss-v4)
3. [https://tailwindcss.com/docs/upgrade-guide](https://tailwindcss.com/docs/upgrade-guide)
4. [https://tailwindcss.com/docs/functions-and-directives](https://tailwindcss.com/docs/functions-and-directives)
5. [https://tailwindcss.com/docs/theme](https://tailwindcss.com/docs/theme)
6. [https://github.com/tailwindlabs/tailwindcss](https://github.com/tailwindlabs/tailwindcss)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |