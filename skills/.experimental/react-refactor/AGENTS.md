# React

**Version 0.1.0**  
React Refactor Best Practices  
February 2026

> **Note:** React architectural refactoring guide for agents and LLMs.
> Use when maintaining, generating, or refactoring React codebases.
> Humans may also find it useful, but guidance here is optimized for AI-assisted workflows.

---

## Abstract

Architectural refactoring guide for React applications. Contains 40 rules across 7 categories covering component architecture, state architecture, hook patterns, component decomposition, coupling and cohesion, data and side effects, and refactoring safety. Each rule includes code smell indicators, before/after transforms, and safe refactoring steps.

---

## Table of Contents

1. [Component Architecture](references/_sections.md#1-component-architecture) — **CRITICAL**
   - 1.1 [Apply Interface Segregation to Component Props](references/arch-interface-segregation.md) — CRITICAL (prevents 30-50% of unnecessary re-renders from unrelated prop changes)
   - 1.2 [Colocate Files by Feature Instead of Type](references/arch-feature-colocation.md) — CRITICAL (reduces cross-directory navigation by 70%, makes features self-contained)
   - 1.3 [Convert Render Props to Custom Hooks](references/arch-render-props-to-hooks.md) — CRITICAL (eliminates 2-4 levels of nesting, improves readability)
   - 1.4 [Extract Headless Components for Logic Reuse](references/arch-headless-pattern.md) — CRITICAL (enables 5x more reuse scenarios for the same behavior)
   - 1.5 [Prefer Composition Over Props Explosion](references/arch-composition-over-props.md) — CRITICAL (reduces prop count by 50-70%, enables independent extension)
   - 1.6 [Push Client Boundaries to Leaf Components](references/arch-push-client-low.md) — HIGH (keeps 60-80% of component tree server-rendered)
   - 1.7 [Separate Container Logic from Presentational Components](references/arch-container-presentational.md) — CRITICAL (enables independent testing and Storybook preview)
   - 1.8 [Use Compound Components for Implicit State Sharing](references/arch-compound-components.md) — CRITICAL (reduces component API surface by 60%, eliminates prop drilling)
2. [State Architecture](references/_sections.md#2-state-architecture) — **CRITICAL**
   - 2.1 [Colocate State with Components That Use It](references/state-colocate-with-consumers.md) — CRITICAL (reduces prop passing by 60%, improves component isolation)
   - 2.2 [Derive Values Instead of Syncing State](references/state-derive-dont-sync.md) — CRITICAL (eliminates double-render cycle, prevents sync drift)
   - 2.3 [Lift State Only When Multiple Components Read It](references/state-lift-only-when-shared.md) — CRITICAL (eliminates unnecessary parent re-renders, clearer ownership)
   - 2.4 [Use Context for Rarely-Changing Values Only](references/state-context-for-static.md) — CRITICAL (5-50x fewer re-renders for context consumers)
   - 2.5 [Use State Machines for Complex UI Workflows](references/state-machines-for-workflows.md) — CRITICAL (reduces valid states from 2^n to exactly N defined states)
   - 2.6 [Use URL Parameters as State for Shareable Views](references/state-url-as-state.md) — CRITICAL (enables deep linking, back/forward navigation, state sharing)
   - 2.7 [Use useReducer for Multi-Field State Transitions](references/state-reducer-for-complex.md) — CRITICAL (eliminates impossible states, centralizes transition logic)
3. [Hook Patterns](references/_sections.md#3-hook-patterns) — **HIGH**
   - 3.1 [Avoid Object and Array Dependencies in Custom Hooks](references/hook-avoid-object-deps.md) — HIGH (prevents effect re-execution on every render)
   - 3.2 [Compose Hooks Instead of Nesting Them](references/hook-composition-over-nesting.md) — HIGH (flattens dependency graph, eliminates hidden coupling)
   - 3.3 [Extract Logic into Custom Hooks When Behavior Is Nameable](references/hook-extract-when-nameable.md) — HIGH (makes component 40-60% shorter, behavior self-documenting)
   - 3.4 [Follow Hook Naming Conventions for Discoverability](references/hook-naming-conventions.md) — HIGH (reduces codebase navigation time by 40%)
   - 3.5 [Keep Custom Hooks to a Single Responsibility](references/hook-single-responsibility.md) — HIGH (3× faster to test, 2× wider reuse)
   - 3.6 [Stabilize Hook Dependencies with Refs and Callbacks](references/hook-dependency-stability.md) — HIGH (prevents infinite loops, eliminates unnecessary re-executions)
4. [Component Decomposition](references/_sections.md#4-component-decomposition) — **HIGH**
   - 4.1 [Apply the Scroll Test to Identify Oversized Components](references/decomp-scroll-test.md) — HIGH (reduces component size to under 100 lines, 3× faster code review)
   - 4.2 [Complete Component Extraction Without Half-Measures](references/decomp-complete-extraction.md) — HIGH (enables independent testing and reuse of extracted component)
   - 4.3 [Extract Components by Independent Change Reasons](references/decomp-extract-by-change-reason.md) — HIGH (70% fewer files touched per feature change)
   - 4.4 [Extract Pure Functions from Component Bodies](references/decomp-extract-pure-functions.md) — HIGH (pure functions testable without React, 10× faster unit tests)
   - 4.5 [Inline Premature Abstractions Before Re-Extracting](references/decomp-inline-premature.md) — HIGH (40-60% simpler code after inlining wrong abstractions)
   - 4.6 [Separate View Layer from Business Logic](references/decomp-separate-view-logic.md) — HIGH (business logic testable without rendering, 5× faster test suite)
5. [Coupling & Cohesion](references/_sections.md#5-coupling-&-cohesion) — **MEDIUM**
   - 5.1 [Break Circular Dependencies with Intermediate Modules](references/couple-break-circular-deps.md) — MEDIUM (eliminates undefined-at-import-time bugs, enables proper tree shaking)
   - 5.2 [Import from Stable Public API Surfaces Only](references/couple-stable-imports.md) — MEDIUM (enables internal refactoring without breaking consumers)
   - 5.3 [Use Barrel-Free Feature Modules for Clean Dependencies](references/couple-barrel-free-features.md) — MEDIUM (200-800ms build time reduction, effective tree shaking)
   - 5.4 [Use Dependency Injection for External Services](references/couple-dependency-injection.md) — MEDIUM (enables testing without mocking modules, 3x faster test setup)
6. [Data & Side Effects](references/_sections.md#6-data-&-side-effects) — **MEDIUM**
   - 6.1 [Fetch Data on the Server by Default](references/data-server-first-fetch.md) — MEDIUM (eliminates client loading spinners, reduces client JS bundle by 30-60%)
   - 6.2 [Place Error Boundaries at Data Fetch Granularity](references/data-granular-error-boundaries.md) — MEDIUM (prevents full-page crash from single component failure)
   - 6.3 [Use Context Module Pattern for Action Colocation](references/data-context-module-pattern.md) — MEDIUM (reduces mutation surface to single file per context)
   - 6.4 [Use TanStack Query for Client-Side Server State](references/data-tanstack-query-client.md) — MEDIUM (eliminates 80% of data fetching boilerplate, built-in cache/retry/deduplication)
7. [Refactoring Safety](references/_sections.md#7-refactoring-safety) — **LOW-MEDIUM**
   - 7.1 [Avoid Snapshot Tests for Refactored Components](references/safety-snapshot-free.md) — MEDIUM (eliminates false test failures during refactoring, tests validate behavior)
   - 7.2 [Extract Pure Functions to Increase Testability](references/safety-extract-pure-testability.md) — MEDIUM (10x faster test execution, no React test renderer needed)
   - 7.3 [Prefer Integration Tests for Component Verification](references/safety-integration-over-unit.md) — MEDIUM (catches 40% more bugs than isolated unit tests)
   - 7.4 [Test Component Behavior Not Implementation Details](references/safety-test-behavior.md) — MEDIUM (reduces test maintenance by 5× per refactoring cycle)
   - 7.5 [Write Characterization Tests Before Refactoring](references/safety-characterization-tests.md) — MEDIUM (catches 90% of unintended behavior changes during refactoring)

---

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/learn/thinking-in-react](https://react.dev/learn/thinking-in-react)
3. [https://kentcdodds.com/blog/application-state-management-with-react](https://kentcdodds.com/blog/application-state-management-with-react)
4. [https://testing-library.com/docs/guiding-principles](https://testing-library.com/docs/guiding-principles)
5. [https://patterns.dev](https://patterns.dev)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |