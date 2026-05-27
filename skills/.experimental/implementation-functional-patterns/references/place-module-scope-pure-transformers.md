---
title: Place pure transformer lambdas at module scope, not inside a component or hook
tags: place, module-scope, identity-stability, jsx, hook-deps
---

## Place pure transformer lambdas at module scope, not inside a component or hook

A pure function — one that depends only on its arguments — gets defined fresh on every render when it lives inside a TSX component body. A new function identity each render is invisible to your eye but visible to React's `===` checks: it defeats `memo` on children that receive it as a prop, fires `useEffect` whose deps include it, and forces the React Compiler to think harder about whether anything actually changed. The fix is mechanical: if the lambda captures no component-local state or prop, hoist it to module scope. There it is created once at module evaluation, has a stable reference forever, is automatically tree-shakable, and can be imported by tests directly.

### Shapes to recognize

- A `const toUpper = (s: string) => s.toUpperCase()` defined inside a component body — captures nothing
- A formatter, parser, validator, or key-extractor defined inside a hook — captures nothing from the hook's closure
- A `useMemo` or `useCallback` wrapping a function that uses no state, no props, no refs — the memo itself is the smell; deletion is the fix, not stabilization
- A child `memo`'d component that re-renders every parent render, with a callback prop pointing to an inline arrow that calls a pure module-scope function (`() => formatPrice(amount)`) — the wrapping arrow is the only unstable thing

**Incorrect (pure transformer defined inside the component):**

```typescript
import { memo, useEffect } from 'react';

function InvoiceRow({ amount, currency, onSelect }: Props) {
  const formatPrice = (n: number) =>
    new Intl.NumberFormat('en-GB', { style: 'currency', currency }).format(n);

  useEffect(() => {
    analytics.track('row-viewed', { display: formatPrice(amount) });
  }, [amount, formatPrice]);

  return <button onClick={onSelect}>{formatPrice(amount)}</button>;
}
```

The `formatPrice` reference is new on every render, so the `useEffect` fires on every render, not just when `amount` changes. Note the dependency is real: `formatPrice` closes over `currency`.

**Correct (split: module-scope helper plus a thin per-render binding when capture is required):**

```typescript
import { memo, useEffect, useCallback } from 'react';

const formatPrice = (amount: number, currency: string) =>
  new Intl.NumberFormat('en-GB', { style: 'currency', currency }).format(amount);

function InvoiceRow({ amount, currency, onSelect }: Props) {
  useEffect(() => {
    analytics.track('row-viewed', { display: formatPrice(amount, currency) });
  }, [amount, currency]);

  return <button onClick={onSelect}>{formatPrice(amount, currency)}</button>;
}
```

`formatPrice` is now a pure two-argument function at module scope: identity-stable, importable, testable in isolation, and not a dependency of the effect. The effect fires only when the data actually changes.

### Common pitfalls

- **Inline arrows inside `.map(...)` in JSX rendering a list.** `arr.map(item => <Row onClick={() => handle(item.id)} />)` allocates `arr.length` closures *per parent render*. For a list of 1000 rows re-rendering on parent state change, that's 1000 closures per render. Either rely on React Compiler v1.0 (which auto-memoizes), or define `Row` to take `itemId` and pass `handle` as a stable prop: `<Row itemId={item.id} onClick={handle} />` with `Row` calling `onClick(itemId)` internally.
- **`useCallback` on a function that doesn't capture anything.** `const fmt = useCallback((n: number) => n.toFixed(2), [])` — empty deps array means the function never changes, but `useCallback` still allocates a Memo cell each render. The honest fix is module-scope: `const fmt = (n: number) => n.toFixed(2)` at the top of the file. `useCallback` is for *captured* closures whose identity you need stable, not for hand-holding pure functions.
- **`useMemo` returning a function.** `const fn = useMemo(() => () => doThing(x), [x])` is a roundabout `useCallback`. Use `useCallback(() => doThing(x), [x])` directly — same meaning, less noise.
- **Module scope vs hook scope for "config-like" helpers.** If the helper depends on a runtime config that's the same for the whole app (theme, locale, feature flags loaded at boot), module scope is still right. If the config genuinely varies per render (per-user, per-route), capture it in the hook or pass it as an argument.

### Performance trade-offs

- **Identity stability is binary.** Either the consumer ( `memo`, `useEffect` deps, `useMemo` deps) skips re-run or it doesn't. A pure transformer at module scope skips correctly; the same transformer in component body never does.
- **Allocation per render:** one closure per inline lambda per component render. For a TSX file with 5 inline lambdas in 100 rendered rows, that's 500 closures per parent render. The cost per closure is tiny (~50 bytes), but the GC pressure compounds; in dev mode (with React strict-mode double-renders), it doubles.
- **React Compiler v1.0 changes the rules.** With the compiler enabled, most inline lambdas in component bodies are auto-memoized. The "module-scope pure transformers" rule still applies because (a) tree-shaking, (b) testability, (c) covers projects without the compiler, but the urgency drops in compiler-enabled code.
- **Tree-shakability:** module-scope pure functions used only by one component get tree-shaken if that component isn't imported. Nested-in-component lambdas don't have that property — they're inside the component's closure.

### When NOT to apply (keep it nested)

- The lambda *does* capture something from the component's render (a state value, a prop, a ref's current, a hook return) — hoisting breaks correctness. Pass the captured value as an argument and the rest of the rule still applies
- The transformer is genuinely one-of-a-kind to this component and would never be reused or tested separately — module-scoping it is fine but not mandatory; pick the placement that matches the lifetime of the concept, not just the mechanical stability win
- The function is inside a generator/iterator/closure factory that *intentionally* produces a new function per call — that's the whole point of the factory; module scope would defeat the design

### Related

- React skill rules for the consumer side: [`memo-use-callback`](../../../.curated/react/references/memo-use-callback.md), [`memo-react-memo`](../../../.curated/react/references/memo-react-memo.md)
- Placement of *capturing* lambdas (the inverse case) is a planned sibling rule

Reference: [MDN — Closures: Creating closures in loops, common mistake](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures#creating_closures_in_loops_a_common_mistake)
