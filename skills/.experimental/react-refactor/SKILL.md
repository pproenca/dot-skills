---
name: react-refactor
description: Architectural refactoring guide for React applications covering component architecture, state architecture, hook patterns, component decomposition, coupling and cohesion, data flow, and refactoring safety. Use when refactoring React codebases, reviewing PRs for architectural issues, decomposing oversized components, or improving module boundaries. Does NOT cover React 19 API usage (see react skill) or performance optimization (see react-optimise skill).
---

# React Refactor Best Practices

Architectural refactoring guide for React applications. Contains 40 rules across 7 categories, prioritized by impact from critical (component and state architecture) to incremental (refactoring safety).

## When to Apply

- Refactoring existing React codebases or planning large-scale restructuring
- Reviewing PRs for architectural issues and code smells
- Decomposing oversized components into focused units
- Extracting reusable hooks from component logic
- Improving testability of React code
- Reducing coupling between feature modules

## Rule Categories

| Category | Impact | Rules | Key Topics |
|----------|--------|-------|------------|
| Component Architecture | CRITICAL | 8 | Compound components, headless pattern, composition over props, client boundaries |
| State Architecture | CRITICAL | 7 | Colocation, state machines, URL state, derived values |
| Hook Patterns | HIGH | 6 | Single responsibility, naming, dependency stability, composition |
| Component Decomposition | HIGH | 6 | Scroll test, extraction by change reason, view/logic separation |
| Coupling & Cohesion | MEDIUM | 4 | Dependency injection, circular deps, stable imports, barrel-free |
| Data & Side Effects | MEDIUM | 4 | Server-first fetch, TanStack Query, error boundaries |
| Refactoring Safety | LOW-MEDIUM | 5 | Characterization tests, behavior testing, integration tests |

## Quick Reference

**Critical patterns** — get these right first:
- Use compound components instead of props explosion
- Colocate state with the components that use it
- Use state machines for complex UI workflows
- Separate container logic from presentational components

**Common mistakes** — avoid these anti-patterns:
- Lifting state to App when only one component reads it
- Using context for rapidly-changing values
- Monolithic hooks that fetch + transform + cache
- Testing implementation details instead of behavior

## Table of Contents

1. [Component Architecture](references/_sections.md#1-component-architecture) — **CRITICAL**
   - 1.1 [Apply Interface Segregation to Component Props](references/arch-interface-segregation.md) — CRITICAL (prevents 30-50% of unnecessary re-renders)
   - 1.2 [Colocate Files by Feature Instead of Type](references/arch-feature-colocation.md) — CRITICAL (reduces cross-directory navigation by 70%)
   - 1.3 [Convert Render Props to Custom Hooks](references/arch-render-props-to-hooks.md) — CRITICAL (eliminates 2-4 levels of nesting)
   - 1.4 [Extract Headless Components for Logic Reuse](references/arch-headless-pattern.md) — CRITICAL (5x more reuse scenarios)
   - 1.5 [Prefer Composition Over Props Explosion](references/arch-composition-over-props.md) — CRITICAL (reduces prop count by 50-70%)
   - 1.6 [Separate Container Logic from Presentational Components](references/arch-container-presentational.md) — CRITICAL (enables independent testing)
   - 1.7 [Use Compound Components for Implicit State Sharing](references/arch-compound-components.md) — CRITICAL (reduces API surface by 60%)
   - 1.8 [Push Client Boundaries to Leaf Components](references/arch-push-client-low.md) — HIGH (keeps 60-80% server-rendered)
2. [State Architecture](references/_sections.md#2-state-architecture) — **CRITICAL**
   - 2.1 [Colocate State with Components That Use It](references/state-colocate-with-consumers.md) — CRITICAL (reduces prop passing by 60%)
   - 2.2 [Derive Values Instead of Syncing State](references/state-derive-dont-sync.md) — CRITICAL (eliminates double-render cycle)
   - 2.3 [Lift State Only When Multiple Components Read It](references/state-lift-only-when-shared.md) — CRITICAL (eliminates unnecessary parent re-renders)
   - 2.4 [Use Context for Rarely-Changing Values Only](references/state-context-for-static.md) — CRITICAL (5-50x fewer re-renders)
   - 2.5 [Use State Machines for Complex UI Workflows](references/state-machines-for-workflows.md) — CRITICAL (reduces valid states from 2^n to N)
   - 2.6 [Use URL Parameters as State for Shareable Views](references/state-url-as-state.md) — CRITICAL (enables deep linking and sharing)
   - 2.7 [Use useReducer for Multi-Field State Transitions](references/state-reducer-for-complex.md) — CRITICAL (eliminates impossible states)
3. [Hook Patterns](references/_sections.md#3-hook-patterns) — **HIGH**
   - 3.1 [Avoid Object and Array Dependencies in Custom Hooks](references/hook-avoid-object-deps.md) — HIGH (prevents effect re-execution every render)
   - 3.2 [Compose Hooks Instead of Nesting Them](references/hook-composition-over-nesting.md) — HIGH (flattens dependency graph)
   - 3.3 [Extract Logic into Custom Hooks When Behavior Is Nameable](references/hook-extract-when-nameable.md) — HIGH (40-60% shorter components)
   - 3.4 [Follow Hook Naming Conventions for Discoverability](references/hook-naming-conventions.md) — HIGH (reduces navigation time by 40%)
   - 3.5 [Keep Custom Hooks to a Single Responsibility](references/hook-single-responsibility.md) — HIGH (3x easier to test)
   - 3.6 [Stabilize Hook Dependencies with Refs and Callbacks](references/hook-dependency-stability.md) — HIGH (prevents infinite loops)
4. [Component Decomposition](references/_sections.md#4-component-decomposition) — **HIGH**
   - 4.1 [Apply the Scroll Test to Identify Oversized Components](references/decomp-scroll-test.md) — HIGH (3x faster code review)
   - 4.2 [Complete Component Extraction Without Half-Measures](references/decomp-complete-extraction.md) — HIGH (enables independent testing and reuse)
   - 4.3 [Extract Components by Independent Change Reasons](references/decomp-extract-by-change-reason.md) — HIGH (70% fewer files touched per change)
   - 4.4 [Extract Pure Functions from Component Bodies](references/decomp-extract-pure-functions.md) — HIGH (10x faster unit tests)
   - 4.5 [Inline Premature Abstractions Before Re-Extracting](references/decomp-inline-premature.md) — HIGH (40-60% simpler code)
   - 4.6 [Separate View Layer from Business Logic](references/decomp-separate-view-logic.md) — HIGH (5x faster test suite)
5. [Coupling & Cohesion](references/_sections.md#5-coupling--cohesion) — **MEDIUM**
   - 5.1 [Break Circular Dependencies with Intermediate Modules](references/couple-break-circular-deps.md) — MEDIUM (eliminates undefined-at-import-time bugs)
   - 5.2 [Import from Stable Public API Surfaces Only](references/couple-stable-imports.md) — MEDIUM (enables internal refactoring)
   - 5.3 [Use Barrel-Free Feature Modules for Clean Dependencies](references/couple-barrel-free-features.md) — MEDIUM (200-800ms build reduction)
   - 5.4 [Use Dependency Injection for External Services](references/couple-dependency-injection.md) — MEDIUM (3x faster test setup)
6. [Data & Side Effects](references/_sections.md#6-data--side-effects) — **MEDIUM**
   - 6.1 [Fetch Data on the Server by Default](references/data-server-first-fetch.md) — MEDIUM (reduces client JS by 30-60%)
   - 6.2 [Place Error Boundaries at Data Fetch Granularity](references/data-granular-error-boundaries.md) — MEDIUM (errors isolated to affected section)
   - 6.3 [Use Context Module Pattern for Action Colocation](references/data-context-module-pattern.md) — MEDIUM (centralizes data mutations)
   - 6.4 [Use TanStack Query for Client-Side Server State](references/data-tanstack-query-client.md) — MEDIUM (eliminates 80% of fetch boilerplate)
7. [Refactoring Safety](references/_sections.md#7-refactoring-safety) — **LOW-MEDIUM**
   - 7.1 [Avoid Snapshot Tests for Refactored Components](references/safety-snapshot-free.md) — LOW-MEDIUM (eliminates false test failures)
   - 7.2 [Extract Pure Functions to Increase Testability](references/safety-extract-pure-testability.md) — LOW-MEDIUM (10x faster test execution)
   - 7.3 [Prefer Integration Tests for Component Verification](references/safety-integration-over-unit.md) — LOW-MEDIUM (catches 40% more bugs)
   - 7.4 [Test Component Behavior Not Implementation Details](references/safety-test-behavior.md) — LOW-MEDIUM (5x fewer test updates)
   - 7.5 [Write Characterization Tests Before Refactoring](references/safety-characterization-tests.md) — LOW-MEDIUM (catches 90% of unintended changes)

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/learn/thinking-in-react](https://react.dev/learn/thinking-in-react)
3. [https://kentcdodds.com/blog/application-state-management-with-react](https://kentcdodds.com/blog/application-state-management-with-react)
4. [https://testing-library.com/docs/guiding-principles](https://testing-library.com/docs/guiding-principles)
5. [https://patterns.dev](https://patterns.dev)

## Related Skills

- For React 19 API best practices, see `react` skill
- For application performance optimization, see `react-optimise` skill
- For client-side form handling, see `react-hook-form` skill
