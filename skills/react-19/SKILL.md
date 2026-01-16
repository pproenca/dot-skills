---
name: react-19-best-practices
description: React 19 performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring React 19 code to ensure optimal performance patterns. Triggers on tasks involving Actions, Server Components, Suspense, useActionState, useOptimistic, use hook, React Compiler, concurrent rendering, or data fetching optimization.
---

# React 19 Best Practices

Comprehensive performance optimization guide for React 19 applications. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new React 19 code with Actions and Server Components
- Implementing forms with useActionState and useFormStatus
- Setting up data fetching with Suspense and the use hook
- Configuring React Compiler and understanding its optimization limits
- Reviewing code for performance issues in concurrent rendering

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Actions & Async Patterns | CRITICAL | `action-` |
| 2 | Data Fetching & Suspense | CRITICAL | `async-` |
| 3 | Server Components | HIGH | `server-` |
| 4 | React Compiler Optimization | HIGH | `compiler-` |
| 5 | State Management | MEDIUM-HIGH | `state-` |
| 6 | Rendering Optimization | MEDIUM | `render-` |
| 7 | Component Patterns | MEDIUM | `component-` |
| 8 | DOM & Hydration | LOW-MEDIUM | `dom-` |

## Quick Reference

### 1. Actions & Async Patterns (CRITICAL)

- `action-form-actions` - Use Form Actions Instead of onSubmit Handlers
- `action-parallel-mutations` - Avoid Sequential Action Calls
- `action-use-action-state` - Use useActionState for Form State Management
- `action-use-form-status` - Use useFormStatus for Nested Form Components
- `action-server-actions` - Use Server Actions for Mutations
- `action-error-boundaries` - Wrap Actions with Error Boundaries

### 2. Data Fetching & Suspense (CRITICAL)

- `async-use-hook-promises` - Use the use Hook for Promise Reading
- `async-no-render-promises` - Never Create Promises During Render
- `async-suspense-boundaries` - Place Suspense Boundaries Strategically
- `async-parallel-fetching` - Fetch Data in Parallel with Promise.all
- `async-use-conditional` - Use the use Hook Conditionally
- `async-error-boundaries` - Pair Suspense with Error Boundaries

### 3. Server Components (HIGH)

- `server-default-to-server` - Default to Server Components
- `server-client-islands` - Isolate Interactivity into Client Islands
- `server-cache-deduplication` - Use React cache() for Request Deduplication
- `server-preload-pattern` - Preload Data to Avoid Waterfalls
- `server-serializable-props` - Pass Only Serializable Data to Client Components

### 4. React Compiler Optimization (HIGH)

- `compiler-trust-automatic-memoization` - Trust the Compiler for Memoization
- `compiler-rules-of-react` - Follow Rules of React for Compiler Compatibility
- `compiler-opt-out` - Apply use-no-memo Directive to Opt Out of Compilation
- `compiler-effect-dependencies` - Use Manual Memoization for Effect Dependencies

### 5. State Management (MEDIUM-HIGH)

- `state-use-optimistic` - Use useOptimistic for Instant Feedback
- `state-use-deferred-value` - Use useDeferredValue for Non-Urgent Updates
- `state-use-transition` - Use useTransition for Non-Blocking State Updates
- `state-functional-updates` - Use Functional setState for Derived Updates
- `state-lazy-initialization` - Use Lazy Initialization for Expensive Initial State

### 6. Rendering Optimization (MEDIUM)

- `render-concurrent-default` - Leverage Concurrent Rendering by Default
- `render-streaming-ssr` - Enable Streaming SSR with Suspense
- `render-avoid-cascading-updates` - Avoid Cascading State Updates in Effects
- `render-keys-for-lists` - Use Stable Keys for List Rendering
- `render-memo-expensive` - Memoize Expensive Child Components
- `render-children-as-props` - Pass Children as Props to Avoid Re-renders

### 7. Component Patterns (MEDIUM)

- `component-ref-as-prop` - Use ref as a Prop Instead of forwardRef
- `component-metadata-in-components` - Define Document Metadata in Components
- `component-use-client-directive` - Place use client at Component Boundaries
- `component-use-server-directive` - Apply use-server Directive for Server Actions Only
- `component-context-provider-placement` - Place Context Providers Outside Client Boundaries

### 8. DOM & Hydration (LOW-MEDIUM)

- `dom-hydration-errors` - Handle Hydration Mismatches Properly
- `dom-ref-cleanup` - Use Ref Cleanup Functions
- `dom-preload-resources` - Preload Critical Resources
- `dom-custom-elements` - Use Custom Elements with Full Prop Support
- `dom-stylesheet-precedence` - Use Stylesheet Precedence for CSS Loading

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/action-form-actions.md
rules/async-use-hook-promises.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
