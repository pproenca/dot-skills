# React 19 Best Practices

**Version 1.4.0**
curated
May 2026

> **Note:** This React guide is mainly for agents and LLMs to follow when
> maintaining, generating, or refactoring React codebases. Humans may also
> find it useful, but guidance here is optimized for automation and consistency
> by AI-assisted workflows.

---

## Abstract

Comprehensive React 19/19.2 best-practices guide for AI agents and LLMs. Contains **49 rules across 9 categories**, prioritized by impact from critical (concurrent rendering, server components) through to cross-cutting codebase hygiene (dedup, dead code, boundary coherence). Covers React 19 headline changes (ref as a regular prop, native document metadata, resource preload APIs, useActionState, useOptimistic, use() hook, Context as provider) and 19.2 features (Activity, useEffectEvent, cacheSignal, React Compiler v1.0).

Rule files describe **pattern shapes** rather than API names and open with a **"Shapes to recognize"** section listing 2–4 syntactic disguises the same break can wear. Selected high-value rules (where pattern-disguise is most common in practice) include a concrete **"In disguise"** incorrect/correct example pair. Category 9 (Codebase Hygiene) adds multi-file findings — duplicated logic, near-duplicate components, dead code, `'use client'` files that don't need the client, prop-shape drift — that single-file rule sweeps cannot produce.

The skill ships a category-major **review/refactor algorithm** ([`references/_review-algorithm.md`](references/_review-algorithm.md)) with two modes (scoped vs whole-repo) and required forcing functions: scope declaration, per-category progress lines, and a coverage table that makes silent category skipping immediately visible.

---

## Table of Contents

1. [Concurrent Rendering](references/_sections.md#1-concurrent-rendering) — **CRITICAL**
   - 1.1 [Preserve hidden subtree state across navigation instead of unmounting](references/conc-activity-component.md) — HIGH (`<Activity>`)
   - 1.2 [Keep previous content visible across navigation by wrapping the update in a transition](references/conc-suspense-fallback.md) — HIGH
   - 1.3 [Trust automatic batching — don't reach for flushSync or unstable_batchedUpdates](references/conc-automatic-batching.md) — HIGH
   - 1.4 [Defer a value you don't own when it drives an expensive child re-render](references/conc-use-deferred-value.md) — CRITICAL (`useDeferredValue`)
   - 1.5 [Mark expensive state updates as low-priority so input stays responsive](references/conc-use-transition.md) — CRITICAL (`useTransition`)
   - 1.6 [Keep render pure — never mutate, subscribe, or read external state during render](references/conc-concurrent-safe.md) — MEDIUM-HIGH
2. [Server Components](references/_sections.md#2-server-components) — **CRITICAL**
   - 2.1 [Quarantine browser-API-dependent libraries inside Client Component wrappers](references/rsc-avoid-client-only-libs.md) — MEDIUM-HIGH
   - 2.2 [Split slow async work behind its own Suspense boundary so fast content streams first](references/rsc-streaming.md) — MEDIUM-HIGH
   - 2.3 [Pull data on the server with async/await — never `useEffect`+`fetch` in a Client Component](references/rsc-data-fetching-server.md) — CRITICAL
   - 2.4 [Push the `'use client'` boundary down to the interactive leaf, not up at the route](references/rsc-server-client-boundary.md) — CRITICAL
   - 2.5 [Only data that the RSC wire format can encode crosses the server→client boundary](references/rsc-serializable-props.md) — HIGH
   - 2.6 [Server content reaches inside a Client Component via `children` or named slots, not by being imported](references/rsc-composition-pattern.md) — HIGH
3. [Actions & Forms](references/_sections.md#3-actions--forms) — **HIGH**
   - 3.1 [Wire form submission through the `action` prop, not a JS-only `onSubmit` handler](references/form-actions.md) — HIGH
   - 3.2 [Lift imperative pending/error/submit bookkeeping into a single declarative form-state hook](references/form-use-action-state.md) — HIGH (`useActionState`)
   - 3.3 [Submit buttons read parent-form pending state from context, not from a prop drilled in](references/form-use-form-status.md) — MEDIUM-HIGH (`useFormStatus`)
   - 3.4 [Show the post-mutation outcome immediately with automatic rollback on failure](references/form-use-optimistic.md) — HIGH (`useOptimistic`)
   - 3.5 [Treat validation as a server-action concern; client checks are an enhancement, never the only gate](references/form-validation.md) — MEDIUM
4. [Data Fetching](references/_sections.md#4-data-fetching) — **HIGH**
   - 4.1 [Independent fetches run concurrently — sequential `await` is a waterfall](references/data-parallel-fetching.md) — MEDIUM-HIGH
   - 4.2 [Per-request memoize data fetchers so multiple components reading the same data don't re-fetch](references/data-cache-deduplication.md) — HIGH (`cache()`)
   - 4.3 [Each Suspense boundary needs an Error Boundary wrapping it — failures must be containable](references/data-error-boundaries.md) — MEDIUM
   - 4.4 [Loading states are declared as Suspense fallbacks, not assembled from `if (loading) return …`](references/data-suspense-data-fetching.md) — HIGH
   - 4.5 [Read promises and conditional context with `use()` instead of `useEffect`+`useState` plumbing](references/data-use-hook.md) — HIGH (`use()`)
   - 4.6 [Page metadata renders as `<title>`/`<meta>`/`<link>` inline — drop helmet-style head managers](references/data-document-metadata.md) — MEDIUM
   - 4.7 [Reach for the imperative resource-hint APIs from `react-dom` instead of hand-rendering `<link rel="preload">`](references/data-resource-hints.md) — MEDIUM
5. [State Management](references/_sections.md#5-state-management) — **MEDIUM-HIGH**
   - 5.1 [Compute derived values in the render body — never mirror them into separate state](references/rstate-derived-values.md) — MEDIUM
   - 5.2 [Each context holds one independently-changing piece of state — split fat contexts apart](references/rstate-context-optimization.md) — MEDIUM
   - 5.3 [When the next state depends on the previous, pass `setX(prev => …)` — not `setX(x + 1)`](references/rstate-functional-updates.md) — MEDIUM-HIGH
   - 5.4 [Pass a function to `useState` when the initial value is expensive — never compute it inline](references/rstate-lazy-initialization.md) — MEDIUM-HIGH
   - 5.5 [Coordinated multi-field state transitions live in a single reducer — not in N sibling `useState` cells](references/rstate-use-reducer.md) — MEDIUM (`useReducer`)
6. [Memoization & Performance](references/_sections.md#6-memoization--performance) — **MEDIUM**
   - 6.1 [Memoize from a measured baseline — don't pre-wrap every value and callback in useMemo/useCallback](references/memo-avoid-premature.md) — MEDIUM
   - 6.2 [Adopt React Compiler v1.0 — let the build memoize, then remove the manual `useMemo`/`useCallback` noise](references/memo-compiler.md) — MEDIUM
   - 6.3 [Wrap expensive pure components in `memo()` only when their props are actually stable](references/memo-react-memo.md) — MEDIUM
   - 6.4 [Stabilize a callback's identity only when something downstream depends on identity stability](references/memo-use-callback.md) — MEDIUM (`useCallback`)
   - 6.5 [Cache a computation between renders only when its inputs are stable and the work is measurably expensive](references/memo-use-memo.md) — MEDIUM (`useMemo`)
7. [Effects & Events](references/_sections.md#7-effects--events) — **MEDIUM**
   - 7.1 [Every effect that subscribes, schedules, or connects must return a cleanup that tears it down](references/effect-cleanup.md) — MEDIUM
   - 7.2 [`useEffect` is for syncing with external systems — never for derived state, mutations, event logic, parent notification, or app init](references/effect-avoid-unnecessary.md) — HIGH
   - 7.3 [Effect deps are reference-compared — pass primitives, not in-render-constructed objects or arrays](references/effect-object-dependencies.md) — MEDIUM
   - 7.4 [Read latest props/state inside an effect's callback without re-subscribing when those values change](references/effect-use-effect-event.md) — MEDIUM (`useEffectEvent`)
   - 7.5 [Subscribe to external mutable state through `useSyncExternalStore`, not `useEffect` + `useState`](references/effect-use-sync-external-store.md) — MEDIUM
8. [Component Patterns](references/_sections.md#8-component-patterns) — **LOW-MEDIUM**
   - 8.1 [Components receive `ref` as a normal destructured prop — drop the `forwardRef` wrapper, drop the drilling](references/rcomp-ref-as-prop.md) — MEDIUM-HIGH
   - 8.2 [Reach for controlled state only when something reads the value on every change — otherwise prefer uncontrolled with `<form action>`](references/rcomp-controlled-components.md) — LOW-MEDIUM
   - 8.3 [When prop count climbs past ~6 with many optional slots, take `children` instead and let callers compose](references/rcomp-composition.md) — LOW-MEDIUM
   - 8.4 [Tie a stateful child's identity to the entity it edits by setting `key={entity.id}` — let React tear down stale state for you](references/rcomp-key-reset.md) — LOW-MEDIUM
   - 8.5 [Use a render prop only when the parent needs to control *rendering* — for logic reuse, prefer a custom hook](references/rcomp-render-props.md) — LOW-MEDIUM
9. [Codebase Hygiene](references/_sections.md#9-codebase-hygiene) — **CROSS-CUTTING** (multi-file findings; required for whole-repo audits)
   - 9.1 [Extract duplicated effect/state shapes into a shared hook](references/cross-extract-shared-logic.md) — HIGH
   - 9.2 [Consolidate near-duplicate components into one with variants or composition](references/cross-component-consolidation.md) — HIGH
   - 9.3 [Delete components, hooks, and utilities with zero importers](references/cross-dead-code.md) — MEDIUM-HIGH
   - 9.4 [Demote 'use client' files whose hook usage doesn't require the client](references/cross-boundary-coherence.md) — HIGH
   - 9.5 [Converge on canonical names when the same concept wears different prop names across components](references/cross-prop-shape-drift.md) — MEDIUM-HIGH

---

## References

1. [React Documentation](https://react.dev)
2. [React 19 Upgrade Guide](https://react.dev/blog/2024/04/25/react-19-upgrade-guide)
3. [React v19 Blog Post](https://react.dev/blog/2024/12/05/react-19)
4. [React 19.2 Blog Post](https://react.dev/blog/2025/10/01/react-19-2)
5. [React Compiler v1.0](https://react.dev/blog/2025/10/07/react-compiler-1)
6. [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
7. [React GitHub Repository](https://github.com/facebook/react)
