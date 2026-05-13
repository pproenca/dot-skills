---
name: react
description: React 19/19.2 modern patterns for concurrent rendering, Server Components, actions, ref-as-prop, document metadata, resource hints, hooks, and memoization — plus a category-major review/refactor algorithm with codebase-level (remove/dedup/reuse) findings. This skill should be used when writing React 19 components, using concurrent features, migrating from React 18, optimizing re-renders, OR auditing/refactoring a React codebase (single file or whole repo). This skill does NOT cover Next.js-specific features like App Router, next.config.js, or Next.js caching (use nextjs-16-app-router skill). For client-side form validation with React Hook Form, use react-hook-form skill.
---

# React 19 Best Practices

Comprehensive React 19/19.2 best-practices guide for AI agents. Contains **49 rules across 9 categories**, prioritized by impact from critical (concurrent rendering, server components) through to cross-cutting codebase hygiene (dedup, dead code, boundary coherence). Reflects React 19 headline changes: `ref` as a regular prop (forwardRef deprecated), native document metadata, resource preload APIs, `useActionState`, `useOptimistic`, `use()` hook, and `<Context>` as provider.

Rule files describe **pattern shapes** (not API names) and open with a **"Shapes to recognize"** section listing 2–4 syntactic disguises the same break can wear. **Selected high-value rules** (those whose disguises are most common in real codebases — form actions, ref-as-prop, derived state, context, the `use()` hook, `useCallback`/`memo` pairing) include an extra concrete **"In disguise"** incorrect/correct example pair to teach pattern detection beyond the grep-friendly cases.

## When to Apply

- Writing new React components or refactoring existing ones
- **Auditing or modernizing a directory, PR, or whole repository** (see [`references/_review-algorithm.md`](references/_review-algorithm.md) for the required procedure)
- Migrating from React 18 to React 19 (forwardRef → ref-as-prop, `<Context.Provider>` → `<Context>`, `useFormState` → `useActionState`)
- Optimizing re-render performance or bundle size
- Using concurrent features (useTransition, useDeferredValue, Activity)
- Setting up Server Components or server/client boundaries
- Implementing form actions, optimistic updates, or data fetching
- Configuring React Compiler for automatic memoization
- Reviewing React code for common anti-patterns or outdated React 18 idioms
- **Finding codebase-level issues** that single-file rules can't see: duplicated logic across files, near-duplicate components, dead code, `'use client'` files that don't need the client, prop-shape drift (see Category 9)

## How to Review or Refactor a Codebase

**When the user asks to review, refactor, modernize, or audit React code — single file or whole repo — follow [`references/_review-algorithm.md`](references/_review-algorithm.md). Do not improvise.**

Four non-negotiables from that doc:

1. **Two modes — never refuse a whole-repo audit.** Pick **Mode A** (scoped, ≤~20 files) or **Mode B** (whole-tree: inventory pass + targeted sweeps + full Category 9). The algorithm tells you how to handle "audit my codebase" without dumping 800 files into context.
2. **Judgment over grep.** Each rule names a *pattern shape*, not a syntactic marker. Read each rule's **Shapes to recognize** section before sweeping — grep finds the easy violations and *misses* the high-value ones (a manually-drilled callback ref because the author dodged `forwardRef`; an `onSubmit` doing the work of `useActionState`; a `useState`+`useEffect` shaped like derived state; a custom hook hiding the fetch dance). Grep is a *trigger*, never a *verdict*.
3. **Category-major, not file-major — with forcing functions.** Sweep one category at a time across all in-scope files in priority order (CRITICAL → … → CROSS-CUTTING). The algorithm requires a **scope declaration**, **per-category progress lines**, and a final **coverage table** (`category × file`, cells ∈ `{clean, N findings, n/a}`). A missing category in the output is *immediately visible*.
4. **Codebase-level findings come from Category 9.** Single-file rules can't tell you "these two components should be one" or "this hook is dead." Category 9 (Codebase Hygiene) sweeps the full inventory at the end and produces remove / dedup / reuse / consolidate findings.

Single-file ad-hoc questions ("is this hook OK?") can go straight to the relevant rule. The algorithm exists for the multi-file and whole-repo cases.

## Rule Categories

| # | Category | Impact | Rules | Key Topics |
|---|----------|--------|-------|------------|
| 1 | Concurrent Rendering | CRITICAL | 6 | useTransition, useDeferredValue, Activity, batching, render purity |
| 2 | Server Components | CRITICAL | 6 | RSC boundaries, data fetching, streaming, serializable props |
| 3 | Actions & Forms | HIGH | 5 | Form actions, declarative form state, useOptimistic, server validation |
| 4 | Data Fetching | HIGH | 7 | use() hook, cache(), Suspense, document metadata, resource hints |
| 5 | State Management | MEDIUM-HIGH | 5 | Derived values, context split, functional updates, reducer |
| 6 | Memoization & Performance | MEDIUM | 5 | React Compiler, useMemo, useCallback, React.memo |
| 7 | Effects & Events | MEDIUM | 5 | useEffectEvent, cleanup, external stores, derived-state anti-pattern |
| 8 | Component Patterns | LOW-MEDIUM | 5 | ref-as-prop, composition, controlled vs uncontrolled, key reset |
| 9 | **Codebase Hygiene** | **CROSS-CUTTING** | **5** | **Dedup, consolidation, dead code, boundary coherence, prop-shape drift** |

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

**Common single-file mistakes** — avoid these anti-patterns:
- Creating promises inside Client Components for `use()` (causes infinite loops)
- Memoizing everything (use React Compiler v1.0+ instead)
- Using effects for derived state, mutations, parent notifications, or app init
- Placing `'use client'` too high in the component tree

**Codebase-level patterns** — surface these in Category 9 sweeps:
- Components/hooks/utilities with zero importers — **delete**
- 2+ files with the same effect/state shape — **extract a shared hook**
- 2+ structurally identical components with drift in labels/icons — **consolidate** with variants or composition
- `'use client'` files whose hook usage doesn't require client execution — **demote** to Server Components (or split into server parent + client island)
- Same conceptual prop carried under different names across components — **converge** on a canonical name

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
