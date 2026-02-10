# React 19 Best Practices

**Version 0.1.0**
curated
February 2026

> **Note:** This React guide is mainly for agents and LLMs to follow when
> maintaining, generating, or refactoring React codebases. Humans may also
> find it useful, but guidance here is optimized for automation and consistency
> by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for React 19/19.2 applications, designed for AI agents and LLMs. Contains 41 rules across 8 categories, prioritized by impact from critical (concurrent rendering, server components) to incremental (component patterns). Covers React 19.2 features including Activity, useEffectEvent, cacheSignal, and React Compiler v1.0. Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Concurrent Rendering](references/_sections.md#1-concurrent-rendering) — **CRITICAL**
   - 1.1 [Use Activity for Pre-Rendering and State Preservation](references/conc-activity-component.md) — HIGH (eliminates navigation re-render cost, preserves user input state)
   - 1.2 [Avoid Suspense Fallback Thrashing](references/conc-suspense-fallback.md) — HIGH (prevents 200-500ms layout shift flicker)
   - 1.3 [Leverage Automatic Batching for Fewer Renders](references/conc-automatic-batching.md) — HIGH (batches multiple setState calls into a single render in all contexts)
   - 1.4 [Use useDeferredValue for Derived Expensive Values](references/conc-use-deferred-value.md) — CRITICAL (prevents jank in derived computations)
   - 1.5 [Use useTransition for Non-Blocking Updates](references/conc-use-transition.md) — CRITICAL (maintains <50ms input latency during heavy state updates)
   - 1.6 [Write Concurrent-Safe Components](references/conc-concurrent-safe.md) — MEDIUM-HIGH (prevents bugs in concurrent rendering)
2. [Server Components](references/_sections.md#2-server-components) — **CRITICAL**
   - 2.1 [Avoid Client-Only Libraries in Server Components](references/rsc-avoid-client-only-libs.md) — MEDIUM-HIGH (prevents build errors, correct component placement)
   - 2.2 [Enable Streaming with Nested Suspense](references/rsc-streaming.md) — MEDIUM-HIGH (progressive loading, faster TTFB)
   - 2.3 [Fetch Data in Server Components](references/rsc-data-fetching-server.md) — CRITICAL (significantly reduces client JS bundle, eliminates client-side data waterfalls)
   - 2.4 [Minimize Server/Client Boundary Crossings](references/rsc-server-client-boundary.md) — CRITICAL (reduces serialization overhead, smaller bundles)
   - 2.5 [Pass Only Serializable Props to Client Components](references/rsc-serializable-props.md) — HIGH (prevents runtime errors, ensures correct hydration)
   - 2.6 [Use Composition to Mix Server and Client Components](references/rsc-composition-pattern.md) — HIGH (maintains server rendering for static content)
3. [Actions & Forms](references/_sections.md#3-actions-&-forms) — **HIGH**
   - 3.1 [Use Form Actions Instead of onSubmit](references/form-actions.md) — HIGH (forms work without JS loaded, eliminates e.preventDefault() boilerplate)
   - 3.2 [Use useActionState for Form State Management](references/form-use-action-state.md) — HIGH (declarative form handling, automatic pending states)
   - 3.3 [Use useFormStatus for Submit Button State](references/form-use-form-status.md) — MEDIUM-HIGH (proper loading indicators, prevents double submission)
   - 3.4 [Use useOptimistic for Instant UI Feedback](references/form-use-optimistic.md) — HIGH (0ms perceived latency for mutations, automatic rollback on server failure)
   - 3.5 [Validate Forms on Server with Actions](references/form-validation.md) — MEDIUM (prevents client-only validation bypass, single source of truth for form errors)
4. [Data Fetching](references/_sections.md#4-data-fetching) — **HIGH**
   - 4.1 [Fetch Data in Parallel with Promise.all](references/data-parallel-fetching.md) — MEDIUM-HIGH (eliminates waterfalls, 2-5x faster)
   - 4.2 [Use cache() for Request Deduplication](references/data-cache-deduplication.md) — HIGH (eliminates duplicate fetches per server request)
   - 4.3 [Use Error Boundaries with Suspense](references/data-error-boundaries.md) — MEDIUM (isolates failures to individual components, prevents full-page crashes)
   - 4.4 [Use Suspense for Declarative Loading States](references/data-suspense-data-fetching.md) — HIGH (eliminates loading state boilerplate, enables parallel data fetch coordination)
   - 4.5 [Use the use() Hook for Promises in Render](references/data-use-hook.md) — HIGH (eliminates useEffect+useState fetch pattern, integrates with Suspense boundaries)
5. [State Management](references/_sections.md#5-state-management) — **MEDIUM-HIGH**
   - 5.1 [Calculate Derived Values During Render](references/rstate-derived-values.md) — MEDIUM (eliminates sync bugs, simpler code)
   - 5.2 [Split Context to Prevent Unnecessary Re-renders](references/rstate-context-optimization.md) — MEDIUM (reduces re-renders from context changes)
   - 5.3 [Use Functional State Updates for Derived Values](references/rstate-functional-updates.md) — MEDIUM-HIGH (prevents stale closures, stable callbacks)
   - 5.4 [Use Lazy Initialization for Expensive Initial State](references/rstate-lazy-initialization.md) — MEDIUM-HIGH (prevents expensive computation on every render)
   - 5.5 [Use useReducer for Complex State Logic](references/rstate-use-reducer.md) — MEDIUM (eliminates impossible state combinations, enables unit-testable state logic)
6. [Memoization & Performance](references/_sections.md#6-memoization-&-performance) — **MEDIUM**
   - 6.1 [Avoid Premature Memoization](references/memo-avoid-premature.md) — MEDIUM (removes 0.1-0.5ms per-render overhead from unnecessary memoization)
   - 6.2 [Leverage React Compiler for Automatic Memoization](references/memo-compiler.md) — MEDIUM (automatic optimization, less manual code)
   - 6.3 [Use React.memo for Expensive Pure Components](references/memo-react-memo.md) — MEDIUM (skips expensive re-renders, 5-50ms savings per unchanged component)
   - 6.4 [Use useCallback for Stable Function References](references/memo-use-callback.md) — MEDIUM (prevents child re-renders from reference changes)
   - 6.5 [Use useMemo for Expensive Calculations](references/memo-use-memo.md) — MEDIUM (skips O(n) recalculations on re-renders with unchanged dependencies)
7. [Effects & Events](references/_sections.md#7-effects-&-events) — **MEDIUM**
   - 7.1 [Always Clean Up Effect Side Effects](references/effect-cleanup.md) — MEDIUM (prevents memory leaks, stale callbacks)
   - 7.2 [Avoid Effects for Derived State and User Events](references/effect-avoid-unnecessary.md) — MEDIUM (eliminates sync bugs, simpler code)
   - 7.3 [Avoid Object and Array Dependencies in Effects](references/effect-object-dependencies.md) — MEDIUM (prevents infinite loops, unnecessary re-runs)
   - 7.4 [Use useEffectEvent for Non-Reactive Logic](references/effect-use-effect-event.md) — MEDIUM (prevents unnecessary effect re-runs from non-reactive value changes)
   - 7.5 [Use useSyncExternalStore for External Subscriptions](references/effect-use-sync-external-store.md) — MEDIUM (prevents tearing in concurrent rendering, ensures SSR-safe external state)
8. [Component Patterns](references/_sections.md#8-component-patterns) — **LOW-MEDIUM**
   - 8.1 [Choose Controlled vs Uncontrolled Appropriately](references/rcomp-controlled-components.md) — LOW-MEDIUM (prevents form state sync bugs, enables real-time validation)
   - 8.2 [Prefer Composition Over Props Explosion](references/rcomp-composition.md) — LOW-MEDIUM (reduces prop drilling depth, enables independent component reuse)
   - 8.3 [Use Key to Reset Component State](references/rcomp-key-reset.md) — LOW-MEDIUM (forces full component remount, eliminates stale state after identity changes)
   - 8.4 [Use Render Props for Inversion of Control](references/rcomp-render-props.md) — LOW-MEDIUM (enables parent-controlled rendering without child prop explosion)

---

## References

1. [React Documentation](https://react.dev)
2. [React v19 Blog Post](https://react.dev/blog/2024/12/05/react-19)
3. [React 19.2 Blog Post](https://react.dev/blog/2025/10/01/react-19-2)
4. [React Compiler v1.0](https://react.dev/blog/2025/10/07/react-compiler-1)
5. [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
6. [React GitHub Repository](https://github.com/facebook/react)
