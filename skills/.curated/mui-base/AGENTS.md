# Best Practices

**Version 1.0.0**  
MUI  
2026-01-17

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive style guide for building headless React component libraries following MUI Base UI patterns. Covers component architecture, naming conventions, file organization, error handling, and code style for unstyled UI primitives.

---

## Table of Contents

1. [Component Patterns](references/_sections.md#1-component-patterns) — **CRITICAL**
   - 1.1 [Add use client Directive](references/comp-use-client-directive.md) — HIGH (enables components to work in React Server Components environments like Next.js App Router)
   - 1.2 [Context Error Messages with Hierarchy](references/comp-context-error-message.md) — HIGH (helps developers quickly fix component structure issues with clear guidance)
   - 1.3 [Create Context with Undefined Default](references/comp-context-undefined-default.md) — HIGH (ensures consumers get clear error messages when used outside provider instead of silent failures)
   - 1.4 [Hook Namespace Exports](references/comp-hook-namespace-exports.md) — MEDIUM (provides consistent type access pattern across hooks and components)
   - 1.5 [Memoize Context Provider Values](references/comp-context-value-memo.md) — HIGH (prevents all context consumers from re-rendering when provider re-renders)
   - 1.6 [Memoize State Objects](references/comp-state-memoization.md) — HIGH (prevents unnecessary re-renders when passing state to render props and child components)
   - 1.7 [Name Props Parameter componentProps](references/comp-props-parameter-naming.md) — HIGH (distinguishes component props from element props after destructuring)
   - 1.8 [Plain Function for Non-DOM Roots](references/comp-plain-function-root.md) — MEDIUM (avoids unnecessary forwardRef overhead for components that don't render DOM elements)
   - 1.9 [Props Destructuring Order](references/comp-props-destructure-order.md) — MEDIUM (maintains consistent code structure across components for easier review)
   - 1.10 [Use forwardRef with Named Function](references/comp-forward-ref-named.md) — CRITICAL (improves debugging with meaningful stack traces and component names in React DevTools)
   - 1.11 [Use useControlled Hook for Dual Modes](references/comp-use-controlled.md) — CRITICAL (provides consistent controlled/uncontrolled behavior with proper warnings for mode switches)
   - 1.12 [Use useRenderElement for DOM Rendering](references/comp-use-render-element.md) — CRITICAL (provides consistent render prop support, className callbacks, and state attributes across all components)
2. [Naming Conventions](references/_sections.md#2-naming-conventions) — **HIGH**
   - 2.1 [Component Naming as ParentPart](references/name-component-naming.md) — CRITICAL (enables predictable API surface and clear component relationships)
   - 2.2 [Constant Naming SCREAMING_SNAKE_CASE](references/name-constants.md) — MEDIUM (clearly distinguishes constants from mutable variables)
   - 2.3 [Context Hook as useComponentContext](references/name-context-hook.md) — HIGH (provides consistent API for accessing context across all components)
   - 2.4 [Context Naming with Suffix](references/name-context-suffix.md) — HIGH (makes context purpose clear and distinguishes from components)
   - 2.5 [Data Attribute Naming lowercase](references/name-data-attributes.md) — HIGH (provides consistent attribute names for CSS selectors and testing)
   - 2.6 [Directory Naming kebab-case](references/name-directory-kebab-case.md) — HIGH (provides consistent filesystem organization that works across all operating systems)
   - 2.7 [Event Type Naming Convention](references/name-event-type.md) — MEDIUM (provides predictable event type names for TypeScript consumers)
   - 2.8 [File Name Matches Primary Export](references/name-file-matches-export.md) — HIGH (enables quick file discovery and consistent import paths)
   - 2.9 [Handler Naming Convention](references/name-handlers.md) — MEDIUM (clearly distinguishes internal handlers from callback props)
   - 2.10 [Hook Naming with use Prefix](references/name-hooks.md) — HIGH (follows React convention and enables lint rule enforcement)
   - 2.11 [Namespace Type Exports](references/name-namespace-type-exports.md) — CRITICAL (provides clean API surface with Component.Props and Component.State patterns)
   - 2.12 [Part Directory Naming lowercase](references/name-part-directory-lowercase.md) — MEDIUM (distinguishes part directories from component directories at a glance)
   - 2.13 [Props Interface as ComponentProps](references/name-props-interface.md) — HIGH (enables consistent type import patterns across all components)
   - 2.14 [Ref Variable Naming with Suffix](references/name-refs.md) — MEDIUM (makes ref usage clear and distinguishes from regular values)
   - 2.15 [State Interface as ComponentState](references/name-state-interface.md) — HIGH (enables consistent state type access for render props and styling)
3. [Organization](references/_sections.md#3-organization) — **HIGH**
   - 3.1 [Component Directory Structure](references/org-component-directory.md) — CRITICAL (enables scalable compound component organization with clear part boundaries)
   - 3.2 [Context File Placement](references/org-context-placement.md) — MEDIUM (keeps context definitions close to providing components)
   - 3.3 [CSS Variables Documentation File](references/org-css-vars-file.md) — LOW (documents CSS custom properties for consumer styling)
   - 3.4 [Data Attributes Documentation File](references/org-data-attributes-file.md) — MEDIUM (provides single source of truth for data attribute names)
   - 3.5 [Dual Barrel Export Pattern](references/org-dual-barrel-exports.md) — HIGH (enables both namespaced and direct import patterns for flexibility)
   - 3.6 [Package-Level Wildcard Exports](references/org-package-exports.md) — HIGH (simplifies main entry point and ensures all components are exported)
   - 3.7 [State Attributes Mapping File](references/org-state-attributes-mapping.md) — MEDIUM (centralizes logic for converting state to data attributes)
   - 3.8 [Test File Colocation](references/org-test-colocation.md) — HIGH (makes tests easy to find and update alongside implementation changes)
4. [Error Handling](references/_sections.md#4-error-handling) — **HIGH**
   - 4.1 [Cancelable Event Pattern](references/err-cancelable-events.md) — CRITICAL (allows consumers to prevent default behavior based on custom logic)
   - 4.2 [Context Error Guidance](references/err-context-error-guidance.md) — HIGH (helps developers fix component hierarchy issues quickly)
   - 4.3 [Deduplicated Warning Messages](references/err-deduplicated-warnings.md) — HIGH (prevents console spam when the same warning triggers repeatedly)
   - 4.4 [Development-Only Warnings](references/err-dev-only-warnings.md) — CRITICAL (ensures warnings don't affect production bundle size or performance)
   - 4.5 [Event Reason Constants](references/err-event-reason-constants.md) — HIGH (provides type-safe event reasons for analytics and conditional handling)
   - 4.6 [Message Prefix Standard](references/err-message-prefix.md) — HIGH (makes it easy to identify which library produced an error)
   - 4.7 [Prop Validation Timing](references/err-prop-validation-timing.md) — MEDIUM (catches issues early without blocking initial render)
   - 4.8 [Type-Safe Event Reasons](references/err-typed-event-reasons.md) — MEDIUM (enables TypeScript to catch invalid reason checks at compile time)
5. [Style](references/_sections.md#5-style) — **MEDIUM**
   - 5.1 [Default Values in Destructuring](references/style-default-values.md) — MEDIUM (keeps default values close to usage and visible in one place)
   - 5.2 [Explicit Undefined in Prop Types](references/style-explicit-undefined.md) — MEDIUM (makes optional prop handling explicit and improves type inference)
   - 5.3 [Internal Import Paths](references/style-internal-imports.md) — MEDIUM (creates clear dependency boundaries between packages)
   - 5.4 [JSDoc Documentation](references/style-jsdoc-documentation.md) — LOW (improves IDE experience and documentation generation)
   - 5.5 [React Import as Namespace](references/style-react-import.md) — HIGH (enables consistent React.* usage and better tree-shaking)

---

## References

1. [[object Object]]([object Object])
2. [[object Object]]([object Object])

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |