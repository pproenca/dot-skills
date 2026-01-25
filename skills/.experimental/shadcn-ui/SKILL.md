---
name: shadcn-ui-best-practices
description: shadcn/ui component library best practices for building accessible, maintainable React interfaces. This skill should be used when writing, reviewing, or refactoring shadcn/ui code to ensure optimal patterns. Triggers on tasks involving shadcn, ui components, Radix primitives, form validation, theming, or data tables.
---

# shadcn/ui Best Practices

Comprehensive best practices guide for shadcn/ui applications, designed for AI agents and LLMs. Contains 48 rules across 8 categories, prioritized by impact to guide component composition, styling, accessibility, and performance optimization.

## When to Apply

Reference these guidelines when:
- Installing and configuring shadcn/ui in a project
- Composing component structures with Dialog, Select, or Dropdown
- Implementing theming with CSS variables and dark mode
- Building accessible forms with validation and error handling
- Creating data tables with TanStack Table integration

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | CLI & Project Setup | CRITICAL | `setup-` |
| 2 | Component Composition | CRITICAL | `comp-` |
| 3 | Styling & Theming | HIGH | `style-` |
| 4 | Accessibility Patterns | HIGH | `access-` |
| 5 | Form Integration | MEDIUM-HIGH | `form-` |
| 6 | Data Display Components | MEDIUM | `data-` |
| 7 | Layout & Navigation | MEDIUM | `layout-` |
| 8 | Performance Optimization | LOW-MEDIUM | `perf-` |

## Quick Reference

### 1. CLI & Project Setup (CRITICAL)

- [`setup-components-json`](references/setup-components-json.md) - Configure components.json before adding components
- [`setup-path-aliases`](references/setup-path-aliases.md) - Configure TypeScript path aliases to match components.json
- [`setup-cn-utility`](references/setup-cn-utility.md) - Create the cn utility before using components
- [`setup-use-cli-not-copy`](references/setup-use-cli-not-copy.md) - Use CLI to add components instead of copy-paste
- [`setup-css-variables-theme`](references/setup-css-variables-theme.md) - Enable CSS variables for consistent theming
- [`setup-rsc-configuration`](references/setup-rsc-configuration.md) - Set RSC flag based on framework support

### 2. Component Composition (CRITICAL)

- [`comp-edit-source-not-wrap`](references/comp-edit-source-not-wrap.md) - Edit component source instead of wrapping
- [`comp-use-aschild-for-custom-elements`](references/comp-use-aschild-for-custom-elements.md) - Use asChild for custom element rendering
- [`comp-compose-dialog-parts`](references/comp-compose-dialog-parts.md) - Compose Dialog with semantic parts
- [`comp-use-cva-for-variants`](references/comp-use-cva-for-variants.md) - Use CVA for component variants
- [`comp-dropdown-menu-structure`](references/comp-dropdown-menu-structure.md) - Structure dropdown menus with required parts
- [`comp-card-semantic-structure`](references/comp-card-semantic-structure.md) - Use Card semantic parts for content organization
- [`comp-icons-data-attributes`](references/comp-icons-data-attributes.md) - Use data-icon attributes for icon spacing
- [`comp-select-controlled-value`](references/comp-select-controlled-value.md) - Use value prop for controlled Select components

### 3. Styling & Theming (HIGH)

- [`style-use-cn-for-merging`](references/style-use-cn-for-merging.md) - Use cn() for all class merging
- [`style-css-variables-naming`](references/style-css-variables-naming.md) - Follow CSS variable naming convention
- [`style-dark-mode-class`](references/style-dark-mode-class.md) - Use class-based dark mode switching
- [`style-extend-not-override`](references/style-extend-not-override.md) - Extend variants instead of overriding base styles
- [`style-oklch-colors`](references/style-oklch-colors.md) - Use OKLCH color format for theme variables
- [`style-register-custom-colors`](references/style-register-custom-colors.md) - Register custom colors with Tailwind theme
- [`style-border-radius-variable`](references/style-border-radius-variable.md) - Use border radius variable for consistent corners

### 4. Accessibility Patterns (HIGH)

- [`access-dialog-title-required`](references/access-dialog-title-required.md) - Always include DialogTitle for screen readers
- [`access-form-field-labels`](references/access-form-field-labels.md) - Associate labels with form controls
- [`access-aria-invalid-errors`](references/access-aria-invalid-errors.md) - Use aria-invalid for form error states
- [`access-icon-button-labels`](references/access-icon-button-labels.md) - Add accessible labels to icon-only buttons
- [`access-checkbox-label-association`](references/access-checkbox-label-association.md) - Wrap Checkbox with Label for click target
- [`access-focus-visible-styles`](references/access-focus-visible-styles.md) - Preserve focus visible styles for keyboard navigation

### 5. Form Integration (MEDIUM-HIGH)

- [`form-react-hook-form-integration`](references/form-react-hook-form-integration.md) - Integrate React Hook Form with Field components
- [`form-field-error-display`](references/form-field-error-display.md) - Display field errors with FieldError component
- [`form-select-with-form`](references/form-select-with-form.md) - Use Controller for Select in React Hook Form
- [`form-submit-button-loading`](references/form-submit-button-loading.md) - Disable submit button during form submission
- [`form-textarea-auto-resize`](references/form-textarea-auto-resize.md) - Use auto-resizing Textarea for long-form input
- [`form-combobox-async-search`](references/form-combobox-async-search.md) - Implement async search with Combobox

### 6. Data Display Components (MEDIUM)

- [`data-tanstack-table-setup`](references/data-tanstack-table-setup.md) - Configure TanStack Table with required row models
- [`data-column-definitions-separate`](references/data-column-definitions-separate.md) - Define columns in separate file for reusability
- [`data-row-actions-dropdown`](references/data-row-actions-dropdown.md) - Use dropdown menu for row actions
- [`data-pagination-component`](references/data-pagination-component.md) - Extract pagination into reusable component
- [`data-empty-state`](references/data-empty-state.md) - Handle empty table state gracefully

### 7. Layout & Navigation (MEDIUM)

- [`layout-sidebar-provider`](references/layout-sidebar-provider.md) - Wrap layout with SidebarProvider
- [`layout-sidebar-collapsible`](references/layout-sidebar-collapsible.md) - Configure sidebar collapsible behavior
- [`layout-sidebar-groups`](references/layout-sidebar-groups.md) - Organize sidebar navigation with groups
- [`layout-sheet-mobile-nav`](references/layout-sheet-mobile-nav.md) - Use Sheet for mobile navigation overlay
- [`layout-breadcrumb-navigation`](references/layout-breadcrumb-navigation.md) - Implement breadcrumbs for deep navigation

### 8. Performance Optimization (LOW-MEDIUM)

- [`perf-dynamic-import-heavy-components`](references/perf-dynamic-import-heavy-components.md) - Dynamic import heavy components
- [`perf-direct-lucide-imports`](references/perf-direct-lucide-imports.md) - Import Lucide icons directly from path
- [`perf-avoid-rerender-callbacks`](references/perf-avoid-rerender-callbacks.md) - Stabilize callback props to prevent re-renders
- [`perf-skeleton-loading-states`](references/perf-skeleton-loading-states.md) - Use Skeleton for loading states
- [`perf-virtualize-long-lists`](references/perf-virtualize-long-lists.md) - Virtualize long lists in Select and Command

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
