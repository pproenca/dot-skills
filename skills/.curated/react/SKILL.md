---
name: react
description: React 19/19.2 modern patterns for concurrent rendering, Server Components, actions, ref-as-prop, document metadata, resource hints, hooks, and memoization. This skill should be used when writing React 19 components, using concurrent features, migrating from React 18, or optimizing re-renders. This skill does NOT cover Next.js-specific features like App Router, next.config.js, or Next.js caching (use nextjs-16-app-router skill). For client-side form validation with React Hook Form, use react-hook-form skill.
---

# React 19 Best Practices

Comprehensive React 19/19.2 best-practices guide for AI agents. Contains 44 rules across 8 categories, prioritized by impact from critical (concurrent rendering, server components) to incremental (component patterns). Reflects React 19 headline changes: `ref` as a regular prop (forwardRef deprecated), native document metadata, resource preload APIs, `useActionState`, `useOptimistic`, `use()` hook, and `<Context>` as provider.

## When to Apply

- Writing new React components or refactoring existing ones
- Migrating from React 18 to React 19 (forwardRef → ref-as-prop, `<Context.Provider>` → `<Context>`, `useFormState` → `useActionState`)
- Optimizing re-render performance or bundle size
- Using concurrent features (useTransition, useDeferredValue, Activity)
- Setting up Server Components or server/client boundaries
- Implementing form actions, optimistic updates, or data fetching
- Configuring React Compiler for automatic memoization
- Reviewing React code for common anti-patterns or outdated React 18 idioms

## How to Review or Refactor Multi-File Sets

**When the user asks to review, refactor, modernize, or audit React code — especially across more than one file — follow [`references/_review-algorithm.md`](references/_review-algorithm.md) instead of going rule-by-rule on each file.**

Two non-negotiables from that doc:

1. **Judgment over grep.** Each rule is keyed off a syntactic marker (`forwardRef`, `useFormState`, `<Context.Provider>`, etc.) — grep finds the easy violations and *misses* the high-value ones (a manually drilled callback ref because the author dodged `forwardRef`; an `onSubmit` doing the work of `useActionState`; a `useState` + `useEffect` shaped like derived state). Use grep only for inventory or post-hoc completeness checks, never as the primary detector.
2. **Category-major, not file-major.** Load all target files first, then sweep **one category at a time across all files** in priority order (CRITICAL → LOW-MEDIUM). Reports group by category, surfacing cross-file clusters. File-by-file iteration causes late files and low-priority categories to silently get skipped.

Single-file ad-hoc questions ("is this hook OK?") can go straight to the relevant rule. The algorithm exists for the multi-file case where consistency and coverage matter.

## Rule Categories

| Category | Impact | Rules | Key Topics |
|----------|--------|-------|------------|
| Concurrent Rendering | CRITICAL | 6 | useTransition, useDeferredValue, Activity, batching |
| Server Components | CRITICAL | 6 | RSC boundaries, data fetching, streaming |
| Actions & Forms | HIGH | 5 | Form actions, useActionState, useOptimistic |
| Data Fetching | HIGH | 7 | use() hook, cache(), Suspense, document metadata, resource hints |
| State Management | MEDIUM-HIGH | 5 | Derived values, context optimization, useReducer |
| Memoization & Performance | MEDIUM | 5 | React Compiler, useMemo, useCallback, React.memo |
| Effects & Events | MEDIUM | 5 | useEffectEvent, cleanup, external stores |
| Component Patterns | LOW-MEDIUM | 5 | ref-as-prop, composition, controlled vs uncontrolled, key reset |

## Quick Reference

**Critical patterns** — get these right first:
- Fetch data in Server Components, not Client Components
- Push `'use client'` boundaries as low as possible
- Use `startTransition` for expensive non-blocking updates
- Use `<Activity>` to preserve state across tab/page switches

**React 19 modern idioms (do NOT generate React 18 patterns):**
- `function C({ ref, ...props })` — never wrap in `forwardRef`
- `<MyContext value={v}>` — never use `<MyContext.Provider>`
- `useActionState` — never use `useFormState`
- `useRef<T>(null)` — always pass an initial value
- Render `<title>`, `<meta>`, `<link>` inline — never reach for `react-helmet`
- `preload`/`preconnect` from `react-dom` — never hand-render `<link rel="preload">`

**Common mistakes** — avoid these anti-patterns:
- Creating promises inside Client Components for `use()` (causes infinite loops)
- Memoizing everything (use React Compiler v1.0+ instead)
- Using effects for derived state, mutations, parent notifications, or app init
- Placing `'use client'` too high in the component tree

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
   - 4.6 [Render Document Metadata Inline, Not via react-helmet](references/data-document-metadata.md) — MEDIUM (eliminates external metadata libraries, native head hoisting)
   - 4.7 [Use react-dom Resource Hints, Not Manual link Tags](references/data-resource-hints.md) — MEDIUM (100-500ms saved on critical above-the-fold assets)
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
   - 7.2 [Avoid Effects for Derived State, Mutations, and Event Logic](references/effect-avoid-unnecessary.md) — HIGH (eliminates extra render passes, sync bugs, and chained-effect cascades)
   - 7.3 [Avoid Object and Array Dependencies in Effects](references/effect-object-dependencies.md) — MEDIUM (prevents infinite loops, unnecessary re-runs)
   - 7.4 [Use useEffectEvent for Non-Reactive Logic](references/effect-use-effect-event.md) — MEDIUM (prevents unnecessary effect re-runs from non-reactive value changes)
   - 7.5 [Use useSyncExternalStore for External Subscriptions](references/effect-use-sync-external-store.md) — MEDIUM (prevents tearing in concurrent rendering, ensures SSR-safe external state)
8. [Component Patterns](references/_sections.md#8-component-patterns) — **LOW-MEDIUM**
   - 8.1 [Use ref as a Regular Prop, Not forwardRef](references/rcomp-ref-as-prop.md) — MEDIUM-HIGH (removes forwardRef wrapper, enables ref cleanup, aligns with the React 19 idiom)
   - 8.2 [Choose Controlled vs Uncontrolled Appropriately](references/rcomp-controlled-components.md) — LOW-MEDIUM (prevents form state sync bugs, enables real-time validation)
   - 8.3 [Prefer Composition Over Props Explosion](references/rcomp-composition.md) — LOW-MEDIUM (reduces prop drilling depth, enables independent component reuse)
   - 8.4 [Use Key to Reset Component State](references/rcomp-key-reset.md) — LOW-MEDIUM (forces full component remount, eliminates stale state after identity changes)
   - 8.5 [Use Render Props for Inversion of Control](references/rcomp-render-props.md) — LOW-MEDIUM (enables parent-controlled rendering without child prop explosion)

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/blog/2024/04/25/react-19-upgrade-guide](https://react.dev/blog/2024/04/25/react-19-upgrade-guide)
3. [https://react.dev/blog/2024/12/05/react-19](https://react.dev/blog/2024/12/05/react-19)
4. [https://react.dev/blog/2025/10/01/react-19-2](https://react.dev/blog/2025/10/01/react-19-2)
5. [https://react.dev/blog/2025/10/07/react-compiler-1](https://react.dev/blog/2025/10/07/react-compiler-1)
6. [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)
7. [https://github.com/facebook/react](https://github.com/facebook/react)

## Related Skills

- For Next.js 16 App Router, see `nextjs-16-app-router` skill
- For client-side form handling, see `react-hook-form` skill
- For data caching with TanStack Query, see `tanstack-query` skill
