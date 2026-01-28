# shadcn/ui

**Version 0.2.0**
shadcn/ui Community
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for shadcn/ui applications, designed for AI agents and LLMs. Contains 58 rules across 10 categories, prioritized by impact from critical (CLI setup, component architecture, accessibility preservation) to incremental (state management). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [CLI & Project Setup](references/_sections.md#1-cli--project-setup) — **CRITICAL**
   - 1.1 [Configure components.json Before Adding Components](references/setup-components-json.md) — CRITICAL (prevents path resolution failures across all component imports)
   - 1.2 [Configure TypeScript Path Aliases to Match components.json](references/setup-path-aliases.md) — CRITICAL (prevents module resolution errors in all component files)
   - 1.3 [Create the cn Utility Before Using Components](references/setup-cn-utility.md) — CRITICAL (required by every shadcn/ui component for class merging)
   - 1.4 [Use CLI to Add Components Instead of Copy-Paste](references/setup-use-cli-not-copy.md) — CRITICAL (ensures correct imports, dependencies, and file structure)
   - 1.5 [Enable CSS Variables for Consistent Theming](references/setup-css-variables-theme.md) — CRITICAL (enables dark mode and design system consistency)
   - 1.6 [Set RSC Flag Based on Framework Support](references/setup-rsc-configuration.md) — HIGH (prevents client/server component mismatch errors)
2. [Component Architecture](references/_sections.md#2-component-architecture) — **CRITICAL**
   - 2.1 [Extend Variants with Class Variance Authority](references/arch-extend-variants-with-cva.md) — CRITICAL (maintains type safety and design consistency)
   - 2.2 [Forward Refs for Composable Components](references/arch-forward-refs-for-composable-components.md) — CRITICAL (enables integration with form libraries and focus management)
   - 2.3 [Isolate Component Variants from Base Styles](references/arch-isolate-component-variants.md) — CRITICAL (prevents style bleeding and maintains component reusability)
   - 2.4 [Preserve Radix Primitive Structure](references/arch-preserve-radix-primitive-structure.md) — CRITICAL (maintains keyboard navigation and focus management)
   - 2.5 [Use asChild for Custom Trigger Elements](references/arch-use-asChild-for-custom-triggers.md) — CRITICAL (preserves accessibility and event handling)
   - 2.6 [Use cn() for Safe Class Merging](references/arch-use-cn-for-class-merging.md) — CRITICAL (prevents Tailwind class conflicts)
3. [Accessibility Preservation](references/_sections.md#3-accessibility-preservation) — **CRITICAL**
   - 3.1 [Ensure Color Contrast Meets WCAG Standards](references/ally-ensure-color-contrast.md) — CRITICAL (enables readability for low vision users)
   - 3.2 [Maintain Focus Management in Modals](references/ally-maintain-focus-management.md) — CRITICAL (prevents 100% keyboard user navigation failure)
   - 3.3 [Preserve ARIA Attributes from Radix Primitives](references/ally-preserve-aria-attributes.md) — CRITICAL (maintains screen reader compatibility)
   - 3.4 [Preserve Keyboard Navigation Patterns](references/ally-preserve-keyboard-navigation.md) — CRITICAL (enables non-mouse users to navigate components)
   - 3.5 [Provide Screen Reader Labels for Icon Buttons](references/ally-provide-sr-only-labels.md) — CRITICAL (enables navigation for visually impaired users)
   - 3.6 [Always Include DialogTitle for Screen Readers](references/ally-dialog-title-required.md) — HIGH (required for ARIA labeling and screen reader announcements)
   - 3.7 [Associate Labels with Form Controls](references/ally-form-field-labels.md) — HIGH (enables screen reader announcements and click-to-focus)
   - 3.8 [Use aria-invalid for Form Error States](references/ally-aria-invalid-errors.md) — HIGH (announces validation errors to screen readers)
   - 3.9 [Wrap Checkbox with Label for Click Target](references/ally-checkbox-label-association.md) — HIGH (expands clickable area and provides screen reader context)
   - 3.10 [Preserve Focus Visible Styles for Keyboard Navigation](references/ally-focus-visible-styles.md) — MEDIUM-HIGH (required for keyboard users to track focus position)
4. [Styling & Theming](references/_sections.md#4-styling--theming) — **HIGH**
   - 4.1 [Apply Mobile-First Responsive Design](references/style-responsive-design-patterns.md) — HIGH (prevents mobile usability failures on 50%+ of traffic)
   - 4.2 [Avoid !important Overrides](references/style-avoid-important-overrides.md) — HIGH (maintains style specificity and component customization)
   - 4.3 [Extend Tailwind Theme for Custom Design Tokens](references/style-use-tailwind-theme-extend.md) — HIGH (maintains design system consistency)
   - 4.4 [Support Dark Mode with CSS Variables](references/style-dark-mode-support.md) — HIGH (provides user preference compliance and reduces eye strain)
   - 4.5 [Use Consistent Spacing Scale](references/style-consistent-spacing-scale.md) — HIGH (creates visual rhythm and reduces design inconsistency)
   - 4.6 [Use CSS Variables for Theme Colors](references/style-use-css-variables-for-theming.md) — HIGH (enables runtime theme switching and consistency)
5. [Form Patterns](references/_sections.md#5-form-patterns) — **HIGH**
   - 5.1 [Handle Async Validation with Debouncing](references/form-handle-async-validation.md) — HIGH (prevents excessive API calls during validation)
   - 5.2 [Reset Form State Correctly After Submission](references/form-reset-form-state-correctly.md) — HIGH (prevents stale data and submission errors)
   - 5.3 [Show Validation Errors at Appropriate Times](references/form-show-validation-errors-correctly.md) — HIGH (improves user experience and reduces frustration)
   - 5.4 [Use React Hook Form with shadcn/ui Forms](references/form-use-react-hook-form-integration.md) — HIGH (eliminates re-renders and provides validation)
   - 5.5 [Use Zod for Schema Validation](references/form-use-zod-for-schema-validation.md) — HIGH (eliminates runtime type errors with full TS inference)
6. [Data Display](references/_sections.md#6-data-display) — **MEDIUM-HIGH**
   - 6.1 [Paginate Large Datasets Server-Side](references/data-paginate-server-side.md) — MEDIUM-HIGH (reduces initial payload by 90%+ for large datasets)
   - 6.2 [Provide Actionable Empty States](references/data-empty-states-with-guidance.md) — MEDIUM-HIGH (increases user action rate by 2-4×)
   - 6.3 [Use Skeleton Components for Loading States](references/data-use-skeleton-loading-states.md) — MEDIUM-HIGH (reduces perceived load time and prevents layout shift)
   - 6.4 [Use TanStack Table for Complex Data Tables](references/data-use-tanstack-table-for-complex-tables.md) — MEDIUM-HIGH (eliminates 200-500 lines of manual table logic)
   - 6.5 [Virtualize Large Lists and Tables](references/data-virtualize-large-lists.md) — MEDIUM-HIGH (10-100× rendering performance for large lists)
7. [Layout & Navigation](references/_sections.md#7-layout--navigation) — **MEDIUM**
   - 7.1 [Wrap Layout with SidebarProvider](references/layout-sidebar-provider.md) — MEDIUM (enables sidebar state management across components)
   - 7.2 [Configure Sidebar Collapsible Behavior](references/layout-sidebar-collapsible.md) — MEDIUM (controls how sidebar collapses on different screen sizes)
   - 7.3 [Organize Sidebar Navigation with Groups](references/layout-sidebar-groups.md) — MEDIUM (improves navigation findability with logical grouping)
   - 7.4 [Use Sheet for Mobile Navigation Overlay](references/layout-sheet-mobile-nav.md) — MEDIUM (proper mobile navigation with slide-in behavior)
   - 7.5 [Implement Breadcrumbs for Deep Navigation](references/layout-breadcrumb-navigation.md) — MEDIUM (provides location context and quick navigation to parent pages)
8. [Component Composition](references/_sections.md#8-component-composition) — **MEDIUM**
   - 8.1 [Combine Command with Popover for Searchable Selects](references/comp-combine-command-with-popover.md) — MEDIUM (reduces selection time by 3-5× for long lists)
   - 8.2 [Compose with Compound Component Patterns](references/comp-compose-with-compound-components.md) — MEDIUM (reduces prop count by 60-80% vs monolithic components)
   - 8.3 [Create Reusable Form Field Components](references/comp-create-reusable-form-fields.md) — MEDIUM (reduces boilerplate and ensures consistency)
   - 8.4 [Nest Dialogs with Proper Focus Management](references/comp-nest-dialogs-correctly.md) — MEDIUM (maintains focus trap hierarchy in nested modals)
   - 8.5 [Use Drawer for Mobile Modal Interactions](references/comp-use-drawer-for-mobile-modals.md) — MEDIUM (reduces touch distance by 40-60% on mobile)
   - 8.6 [Use Slot Pattern for Flexible Content Areas](references/comp-use-slot-pattern-for-flexibility.md) — MEDIUM (enables custom content injection without prop explosion)
9. [Performance Optimization](references/_sections.md#9-performance-optimization) — **MEDIUM**
   - 9.1 [Avoid Unnecessary Re-renders in Forms](references/perf-avoid-unnecessary-rerenders-in-forms.md) — MEDIUM (prevents full form re-render on every keystroke)
   - 9.2 [Debounce Search and Filter Inputs](references/perf-debounce-search-inputs.md) — MEDIUM (reduces API calls by 80-90% during typing)
   - 9.3 [Lazy Load Heavy Components](references/perf-lazy-load-heavy-components.md) — MEDIUM (reduces initial bundle by 30-50%)
   - 9.4 [Memoize Expensive Component Renders](references/perf-memoize-expensive-renders.md) — MEDIUM (prevents unnecessary re-renders in lists and data displays)
   - 9.5 [Optimize Icon Imports from Lucide](references/perf-optimize-icon-imports.md) — MEDIUM (reduces bundle by 200-500KB with direct imports)
10. [State Management](references/_sections.md#10-state-management) — **LOW-MEDIUM**
    - 10.1 [Colocate State with the Components That Use It](references/state-colocate-state-with-components.md) — LOW-MEDIUM (improves code organization and reduces unnecessary coupling)
    - 10.2 [Lift State to the Appropriate Level](references/state-lift-state-to-appropriate-level.md) — LOW-MEDIUM (prevents prop drilling and enables component communication)
    - 10.3 [Prefer Uncontrolled Components for Simple Inputs](references/state-prefer-uncontrolled-for-simple-inputs.md) — LOW-MEDIUM (reduces state management overhead for simple cases)
    - 10.4 [Use Controlled State for Dialogs Triggered Externally](references/state-use-controlled-dialog-state.md) — LOW-MEDIUM (enables programmatic dialog control from parent components)

---

## References

1. [https://ui.shadcn.com/](https://ui.shadcn.com/)
2. [https://www.radix-ui.com/primitives/docs/overview/accessibility](https://www.radix-ui.com/primitives/docs/overview/accessibility)
3. [https://vercel.com/academy/shadcn-ui](https://vercel.com/academy/shadcn-ui)
4. [https://react-hook-form.com/](https://react-hook-form.com/)
5. [https://tailwindcss.com/](https://tailwindcss.com/)
6. [https://cva.style/docs](https://cva.style/docs)
7. [https://tanstack.com/table/latest](https://tanstack.com/table/latest)
8. [https://tanstack.com/virtual/latest](https://tanstack.com/virtual/latest)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
