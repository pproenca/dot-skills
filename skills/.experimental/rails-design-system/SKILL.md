---
name: rails-design-system
description: Ruby on Rails design system guidelines for building consistent, maintainable UI with minimal abstraction. This skill should be used when creating or refactoring Rails views, partials, components, form builders, helpers, Stimulus controllers, Turbo Frames, Turbo Streams, or design tokens. Triggers on tasks involving ERB partials, Turbo navigation, Turbo Streams, ViewComponent, Phlex, Tailwind design tokens, custom form builders, view helpers, Stimulus behaviors, Import Maps, Lookbook previews, or design system consistency audits.
---

# Community Ruby on Rails Design System Best Practices

Comprehensive design system guide for Ruby on Rails applications, maintained by Community. Contains 51 rules across 9 categories, prioritized by impact to guide automated refactoring and code generation. Covers the full Rails frontend stack: Turbo (Drive, Frames, Streams), Stimulus, ERB partials, design tokens, form builders, and view helpers. Complements `rails-dev` (controllers, models, queries) and `tailwind` (CSS patterns) by covering the systematic UI component architecture layer.

## When to Apply

Reference these guidelines when:
- Deciding whether to extract a partial, component, or helper
- Defining design tokens with Tailwind CSS `@theme`
- Creating or refactoring ERB partials with explicit locals
- Decomposing pages into Turbo Frames for targeted updates
- Using Turbo Streams for multi-element CRUD updates
- Coordinating Turbo navigation with Stimulus controllers
- Building ViewComponent or Phlex components for complex UI
- Implementing a custom FormBuilder for consistent forms
- Writing view helpers for badges, icons, and conditional classes
- Adding Stimulus controllers for interactive behaviors
- Managing JavaScript dependencies with Import Maps
- Auditing the codebase for UI duplication and naming drift

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Design Decisions | CRITICAL | `decide-` |
| 2 | Design Tokens | CRITICAL | `token-` |
| 3 | Turbo Integration | HIGH | `turbo-` |
| 4 | Partial Patterns | HIGH | `partial-` |
| 5 | Component Architecture | HIGH | `comp-` |
| 6 | Form System | MEDIUM-HIGH | `form-` |
| 7 | Helper Patterns | MEDIUM | `helper-` |
| 8 | Stimulus Behaviors | MEDIUM | `stim-` |
| 9 | Consistency & Organization | LOW-MEDIUM | `org-` |

## Quick Reference

### 1. Design Decisions (CRITICAL)

- [`decide-three-uses-rule`](references/decide-three-uses-rule.md) - Extract only after a pattern appears in 3+ places
- [`decide-partial-vs-component`](references/decide-partial-vs-component.md) - Choose partials for simple reuse, components for complex logic
- [`decide-helper-vs-partial`](references/decide-helper-vs-partial.md) - Use helpers for tiny HTML fragments, partials for layout blocks
- [`decide-prove-then-extract`](references/decide-prove-then-extract.md) - Prove patterns in production before abstracting
- [`decide-avoid-wrapper-components`](references/decide-avoid-wrapper-components.md) - Avoid thin wrappers that add indirection without value
- [`decide-design-system-scope`](references/decide-design-system-scope.md) - Scope the design system to what the app actually needs

### 2. Design Tokens (CRITICAL)

- [`token-tailwind-theme`](references/token-tailwind-theme.md) - Define tokens with Tailwind CSS @theme directive
- [`token-semantic-color-names`](references/token-semantic-color-names.md) - Name colors by purpose, not appearance
- [`token-spacing-scale`](references/token-spacing-scale.md) - Use a constrained spacing scale for consistent layout
- [`token-typography-scale`](references/token-typography-scale.md) - Define a typography scale for headings, body, and UI text
- [`token-component-tokens`](references/token-component-tokens.md) - Create component-level tokens for repeated patterns
- [`token-share-tokens-with-ruby`](references/token-share-tokens-with-ruby.md) - Share token values between CSS and Ruby when needed

### 3. Turbo Integration (HIGH)

- [`turbo-drive-defaults`](references/turbo-drive-defaults.md) - Let Turbo Drive handle navigation by default
- [`turbo-frame-decompose`](references/turbo-frame-decompose.md) - Decompose pages into Turbo Frames for targeted updates
- [`turbo-frame-naming`](references/turbo-frame-naming.md) - Name Turbo Frames with dom_id conventions
- [`turbo-frame-vs-stream`](references/turbo-frame-vs-stream.md) - Choose Turbo Frames vs Turbo Streams by scope of change
- [`turbo-stream-crud`](references/turbo-stream-crud.md) - Use Turbo Streams for multi-element page updates
- [`turbo-stimulus-coordination`](references/turbo-stimulus-coordination.md) - Coordinate Turbo and Stimulus without conflicts

### 4. Partial Patterns (HIGH)

- [`partial-explicit-locals`](references/partial-explicit-locals.md) - Always pass locals explicitly to partials
- [`partial-presenter-objects`](references/partial-presenter-objects.md) - Use presenter objects to encapsulate view logic
- [`partial-naming-conventions`](references/partial-naming-conventions.md) - Name partials by what they render, prefixed with underscore
- [`partial-yield-blocks`](references/partial-yield-blocks.md) - Use yield blocks for flexible partial layouts
- [`partial-collection-with-spacer`](references/partial-collection-with-spacer.md) - Use collection rendering with spacer templates
- [`partial-shared-directory`](references/partial-shared-directory.md) - Place cross-controller partials in app/views/shared

### 5. Component Architecture (HIGH)

- [`comp-when-to-use`](references/comp-when-to-use.md) - Use components when partials outgrow simple rendering
- [`comp-explicit-args`](references/comp-explicit-args.md) - Define explicit typed arguments for every component
- [`comp-slots-for-markup`](references/comp-slots-for-markup.md) - Use slots for caller-provided markup blocks
- [`comp-test-rendered-output`](references/comp-test-rendered-output.md) - Test components by asserting on rendered HTML

### 6. Form System (MEDIUM-HIGH)

- [`form-custom-builder`](references/form-custom-builder.md) - Create a custom FormBuilder for consistent form rendering
- [`form-set-default-builder`](references/form-set-default-builder.md) - Set the custom builder as the application default
- [`form-error-display`](references/form-error-display.md) - Display field errors inline with consistent markup
- [`form-accessible-labels`](references/form-accessible-labels.md) - Generate accessible labels and ARIA attributes automatically
- [`form-group-wrapper`](references/form-group-wrapper.md) - Wrap label + input + error in a consistent group element
- [`form-button-consistency`](references/form-button-consistency.md) - Standardize submit buttons through the form builder

### 7. Helper Patterns (MEDIUM)

- [`helper-tag-helpers`](references/helper-tag-helpers.md) - Use tag helpers for small generated HTML fragments
- [`helper-conditional-classes`](references/helper-conditional-classes.md) - Use class_names for conditional CSS classes
- [`helper-icon-helper`](references/helper-icon-helper.md) - Create an icon helper for consistent icon rendering
- [`helper-badge-pattern`](references/helper-badge-pattern.md) - Build a badge helper for status indicators
- [`helper-scope-to-domain`](references/helper-scope-to-domain.md) - Scope helpers to specific domains, not generic utilities

### 8. Stimulus Behaviors (MEDIUM)

- [`stim-general-purpose`](references/stim-general-purpose.md) - Write general-purpose controllers, not one-off scripts
- [`stim-data-attribute-config`](references/stim-data-attribute-config.md) - Configure behavior through data attributes, not JavaScript
- [`stim-small-controllers`](references/stim-small-controllers.md) - Keep controllers small and single-responsibility
- [`stim-composable-controllers`](references/stim-composable-controllers.md) - Compose multiple controllers on one element
- [`stim-use-outlets`](references/stim-use-outlets.md) - Use outlets for cross-controller communication
- [`stim-leverage-library`](references/stim-leverage-library.md) - Use stimulus-components before writing custom controllers

### 9. Consistency & Organization (LOW-MEDIUM)

- [`org-naming-conventions`](references/org-naming-conventions.md) - Follow consistent naming across partials, components, and helpers
- [`org-file-structure`](references/org-file-structure.md) - Organize design system files in predictable locations
- [`org-deduplication-audit`](references/org-deduplication-audit.md) - Periodically audit views for duplicated patterns
- [`org-import-maps`](references/org-import-maps.md) - Use Import Maps for zero-build JavaScript delivery
- [`org-preview-with-lookbook`](references/org-preview-with-lookbook.md) - Preview components with Lookbook in development
- [`org-document-design-decisions`](references/org-document-design-decisions.md) - Document design system decisions in ADRs

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
