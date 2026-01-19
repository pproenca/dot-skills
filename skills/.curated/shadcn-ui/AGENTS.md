# shadcn/ui

**Version 0.1.0**  
shadcn/ui Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for shadcn/ui applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (component architecture, accessibility preservation) to incremental (state management). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Component Architecture](references/_sections.md#1-component-architecture) — **CRITICAL**
   - 1.1 [Extend Variants with Class Variance Authority](references/arch-extend-variants-with-cva.md) — CRITICAL (maintains type safety and design consistency)
   - 1.2 [Forward Refs for Composable Components](references/arch-forward-refs-for-composable-components.md) — CRITICAL (enables integration with form libraries and focus management)
   - 1.3 [Isolate Component Variants from Base Styles](references/arch-isolate-component-variants.md) — CRITICAL (prevents style bleeding and maintains component reusability)
   - 1.4 [Preserve Radix Primitive Structure](references/arch-preserve-radix-primitive-structure.md) — CRITICAL (maintains keyboard navigation and focus management)
   - 1.5 [Use asChild for Custom Trigger Elements](references/arch-use-asChild-for-custom-triggers.md) — CRITICAL (preserves accessibility and event handling)
   - 1.6 [Use cn() for Safe Class Merging](references/arch-use-cn-for-class-merging.md) — CRITICAL (prevents Tailwind class conflicts)
2. [Accessibility Preservation](references/_sections.md#2-accessibility-preservation) — **CRITICAL**
   - 2.1 [Ensure Color Contrast Meets WCAG Standards](references/ally-ensure-color-contrast.md) — CRITICAL (enables readability for low vision users)
   - 2.2 [Maintain Focus Management in Modals](references/ally-maintain-focus-management.md) — CRITICAL (prevents 100% keyboard user navigation failure)
   - 2.3 [Preserve ARIA Attributes from Radix Primitives](references/ally-preserve-aria-attributes.md) — CRITICAL (maintains screen reader compatibility)
   - 2.4 [Preserve Keyboard Navigation Patterns](references/ally-preserve-keyboard-navigation.md) — CRITICAL (enables non-mouse users to navigate components)
   - 2.5 [Provide Screen Reader Labels for Icon Buttons](references/ally-provide-sr-only-labels.md) — CRITICAL (enables navigation for visually impaired users)
3. [Styling & Theming](references/_sections.md#3-styling-&-theming) — **HIGH**
   - 3.1 [Apply Mobile-First Responsive Design](references/style-responsive-design-patterns.md) — HIGH (prevents mobile usability failures on 50%+ of traffic)
   - 3.2 [Avoid !important Overrides](references/style-avoid-important-overrides.md) — HIGH (maintains style specificity and component customization)
   - 3.3 [Extend Tailwind Theme for Custom Design Tokens](references/style-use-tailwind-theme-extend.md) — HIGH (maintains design system consistency)
   - 3.4 [Support Dark Mode with CSS Variables](references/style-dark-mode-support.md) — HIGH (provides user preference compliance and reduces eye strain)
   - 3.5 [Use Consistent Spacing Scale](references/style-consistent-spacing-scale.md) — HIGH (creates visual rhythm and reduces design inconsistency)
   - 3.6 [Use CSS Variables for Theme Colors](references/style-use-css-variables-for-theming.md) — HIGH (enables runtime theme switching and consistency)
4. [Form Patterns](references/_sections.md#4-form-patterns) — **HIGH**
   - 4.1 [Handle Async Validation with Debouncing](references/form-handle-async-validation.md) — HIGH (prevents excessive API calls during validation)
   - 4.2 [Reset Form State Correctly After Submission](references/form-reset-form-state-correctly.md) — HIGH (prevents stale data and submission errors)
   - 4.3 [Show Validation Errors at Appropriate Times](references/form-show-validation-errors-correctly.md) — HIGH (improves user experience and reduces frustration)
   - 4.4 [Use React Hook Form with shadcn/ui Forms](references/form-use-react-hook-form-integration.md) — HIGH (eliminates re-renders and provides validation)
   - 4.5 [Use Zod for Schema Validation](references/form-use-zod-for-schema-validation.md) — HIGH (eliminates runtime type errors with full TS inference)
5. [Data Display](references/_sections.md#5-data-display) — **MEDIUM-HIGH**
   - 5.1 [Paginate Large Datasets Server-Side](references/data-paginate-server-side.md) — MEDIUM-HIGH (reduces initial payload by 90%+ for large datasets)
   - 5.2 [Provide Actionable Empty States](references/data-empty-states-with-guidance.md) — MEDIUM-HIGH (increases user action rate by 2-4×)
   - 5.3 [Use Skeleton Components for Loading States](references/data-use-skeleton-loading-states.md) — MEDIUM-HIGH (reduces perceived load time and prevents layout shift)
   - 5.4 [Use TanStack Table for Complex Data Tables](references/data-use-tanstack-table-for-complex-tables.md) — MEDIUM-HIGH (eliminates 200-500 lines of manual table logic)
   - 5.5 [Virtualize Large Lists and Tables](references/data-virtualize-large-lists.md) — MEDIUM-HIGH (10-100× rendering performance for large lists)
6. [Component Composition](references/_sections.md#6-component-composition) — **MEDIUM**
   - 6.1 [Combine Command with Popover for Searchable Selects](references/comp-combine-command-with-popover.md) — MEDIUM (reduces selection time by 3-5× for long lists)
   - 6.2 [Compose with Compound Component Patterns](references/comp-compose-with-compound-components.md) — MEDIUM (reduces prop count by 60-80% vs monolithic components)
   - 6.3 [Create Reusable Form Field Components](references/comp-create-reusable-form-fields.md) — MEDIUM (reduces boilerplate and ensures consistency)
   - 6.4 [Nest Dialogs with Proper Focus Management](references/comp-nest-dialogs-correctly.md) — MEDIUM (maintains focus trap hierarchy in nested modals)
   - 6.5 [Use Drawer for Mobile Modal Interactions](references/comp-use-drawer-for-mobile-modals.md) — MEDIUM (reduces touch distance by 40-60% on mobile)
   - 6.6 [Use Slot Pattern for Flexible Content Areas](references/comp-use-slot-pattern-for-flexibility.md) — MEDIUM (enables custom content injection without prop explosion)
7. [Performance Optimization](references/_sections.md#7-performance-optimization) — **MEDIUM**
   - 7.1 [Avoid Unnecessary Re-renders in Forms](references/perf-avoid-unnecessary-rerenders-in-forms.md) — MEDIUM (prevents full form re-render on every keystroke)
   - 7.2 [Debounce Search and Filter Inputs](references/perf-debounce-search-inputs.md) — MEDIUM (reduces API calls by 80-90% during typing)
   - 7.3 [Lazy Load Heavy Components](references/perf-lazy-load-heavy-components.md) — MEDIUM (reduces initial bundle by 30-50%)
   - 7.4 [Memoize Expensive Component Renders](references/perf-memoize-expensive-renders.md) — MEDIUM (prevents unnecessary re-renders in lists and data displays)
   - 7.5 [Optimize Icon Imports from Lucide](references/perf-optimize-icon-imports.md) — MEDIUM (reduces bundle by 200-500KB with direct imports)
8. [State Management](references/_sections.md#8-state-management) — **LOW-MEDIUM**
   - 8.1 [Colocate State with the Components That Use It](references/state-colocate-state-with-components.md) — LOW-MEDIUM (improves code organization and reduces unnecessary coupling)
   - 8.2 [Lift State to the Appropriate Level](references/state-lift-state-to-appropriate-level.md) — LOW-MEDIUM (prevents prop drilling and enables component communication)
   - 8.3 [Prefer Uncontrolled Components for Simple Inputs](references/state-prefer-uncontrolled-for-simple-inputs.md) — LOW-MEDIUM (reduces state management overhead for simple cases)
   - 8.4 [Use Controlled State for Dialogs Triggered Externally](references/state-use-controlled-dialog-state.md) — LOW-MEDIUM (enables programmatic dialog control from parent components)

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