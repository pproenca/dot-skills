---
name: react
description: React 19 performance optimization guidelines for concurrent rendering, Server Components, actions, hooks, and memoization (formerly react-19). This skill should be used when writing React 19 components, using concurrent features, or optimizing re-renders. This skill does NOT cover Next.js-specific features like App Router, next.config.js, or Next.js caching (use nextjs-16-app-router skill). For client-side form validation with React Hook Form, use react-hook-form skill.
---

# React Community React 19 Best Practices

Comprehensive performance optimization guide for React 19 applications, maintained by the React Community. Contains 40 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new React 19 components and hooks
- Using concurrent features like useTransition and useDeferredValue
- Implementing Server Components and data fetching
- Creating forms with Actions and useActionState
- Optimizing re-renders with memoization strategies

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Concurrent Rendering | CRITICAL | `conc-` |
| 2 | Server Components | CRITICAL | `rsc-` |
| 3 | Actions & Forms | HIGH | `form-` |
| 4 | Data Fetching | HIGH | `data-` |
| 5 | State Management | MEDIUM-HIGH | `rstate-` |
| 6 | Memoization & Performance | MEDIUM | `memo-` |
| 7 | Effects & Events | MEDIUM | `effect-` |
| 8 | Component Patterns | LOW-MEDIUM | `rcomp-` |

## Quick Reference

### 1. Concurrent Rendering (CRITICAL)

- `conc-use-transition` - Use useTransition for Non-Blocking Updates
- `conc-use-deferred-value` - Use useDeferredValue for Derived Expensive Values
- `conc-automatic-batching` - Leverage Automatic Batching for Fewer Renders
- `conc-suspense-fallback` - Avoid Suspense Fallback Thrashing
- `conc-concurrent-safe` - Write Concurrent-Safe Components

### 2. Server Components (CRITICAL)

- `rsc-server-client-boundary` - Minimize Server/Client Boundary Crossings
- `rsc-data-fetching-server` - Fetch Data in Server Components
- `rsc-serializable-props` - Pass Only Serializable Props to Client Components
- `rsc-composition-pattern` - Use Composition to Mix Server and Client Components
- `rsc-avoid-client-only-libs` - Avoid Client-Only Libraries in Server Components
- `rsc-streaming` - Enable Streaming with Nested Suspense

### 3. Actions & Forms (HIGH)

- `form-use-action-state` - Use useActionState for Form State Management
- `form-use-optimistic` - Use useOptimistic for Instant UI Feedback
- `form-actions` - Use Form Actions Instead of onSubmit
- `form-use-form-status` - Use useFormStatus for Submit Button State
- `form-validation` - Validate Forms on Server with Actions

### 4. Data Fetching (HIGH)

- `data-use-hook` - Use the use() Hook for Promises in Render
- `data-suspense-data-fetching` - Use Suspense for Declarative Loading States
- `data-cache-deduplication` - Use cache() for Request Deduplication
- `data-parallel-fetching` - Fetch Data in Parallel with Promise.all
- `data-error-boundaries` - Use Error Boundaries with Suspense

### 5. State Management (MEDIUM-HIGH)

- `rstate-functional-updates` - Use Functional State Updates for Derived Values
- `rstate-lazy-initialization` - Use Lazy Initialization for Expensive Initial State
- `rstate-use-reducer` - Use useReducer for Complex State Logic
- `rstate-context-optimization` - Split Context to Prevent Unnecessary Re-renders
- `rstate-derived-values` - Calculate Derived Values During Render

### 6. Memoization & Performance (MEDIUM)

- `memo-use-memo` - Use useMemo for Expensive Calculations
- `memo-use-callback` - Use useCallback for Stable Function References
- `memo-react-memo` - Use React.memo for Expensive Pure Components
- `memo-compiler` - Leverage React Compiler for Automatic Memoization
- `memo-avoid-premature` - Avoid Premature Memoization

### 7. Effects & Events (MEDIUM)

- `effect-avoid-unnecessary` - Avoid Effects for Derived State and User Events
- `effect-use-sync-external-store` - Use useSyncExternalStore for External Subscriptions
- `effect-cleanup` - Always Clean Up Effect Side Effects
- `effect-use-effect-event` - Use useEffectEvent for Non-Reactive Logic
- `effect-object-dependencies` - Avoid Object and Array Dependencies in Effects

### 8. Component Patterns (LOW-MEDIUM)

- `rcomp-composition` - Prefer Composition Over Props Explosion
- `rcomp-render-props` - Use Render Props for Inversion of Control
- `rcomp-controlled-components` - Choose Controlled vs Uncontrolled Appropriately
- `rcomp-key-reset` - Use Key to Reset Component State

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- Example: [conc-use-transition](references/conc-use-transition.md)
- Example: [rsc-server-client-boundary](references/rsc-server-client-boundary.md)

## Related Skills

- For Next.js 16 App Router, see `nextjs-16-app-router` skill
- For client-side form handling, see `react-hook-form` skill
- For data caching with TanStack Query, see `tanstack-query` skill

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
