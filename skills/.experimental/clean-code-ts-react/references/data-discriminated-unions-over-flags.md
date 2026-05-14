---
title: Use Discriminated Unions Over Boolean Flags
impact: MEDIUM-HIGH
impactDescription: encodes legal states only so the compiler enforces invariants
tags: data, types, state, discriminated-union
---

## Use Discriminated Unions Over Boolean Flags

A type with N independent boolean flags has 2^N possible states, most of which are illegal — `isLoading && data && error` should never happen, but a flag-based type says it can. Discriminated unions make only the LEGAL states representable, so the compiler enforces what comments used to ask the reader to remember. Bugs that used to require a unit test become unrepresentable.

**Incorrect (flag soup admits impossible combinations):**

```tsx
// Reader has to mentally exclude isLoading && data, error && data, etc.
type OrderState = {
  status: string;
  isLoading: boolean;
  error: string | null;
  data: Order | null;
};

function OrderView({ state }: { state: OrderState }) {
  if (state.isLoading) return <Spinner />;
  if (state.error) return <ErrorBanner message={state.error} />;
  // Compiler thinks state.data could be null here — must defensive-check
  if (state.data) return <OrderDetails order={state.data} />;
  return null;
}
```

**Correct (only legal states are representable):**

```tsx
// Reader doesn't have to defend against impossible combinations.
type OrderState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Order }
  | { status: 'error'; error: string };

function OrderView({ state }: { state: OrderState }) {
  switch (state.status) {
    case 'loading': return <Spinner />;
    case 'error':   return <ErrorBanner message={state.error} />;
    case 'success': return <OrderDetails order={state.data} />; // data is non-null here
    case 'idle':    return null;
  }
}
```

**When NOT to apply this pattern:**
- Standalone 2-state booleans with no related fields — `isPublic: boolean` on a `Post` doesn't need a union.
- Very wide unions (>6 variants) where readability suffers more than it gains — reach for a state-machine library (XState) instead of hand-rolled tags.
- Legacy code whose flag-shaped state is part of a published API contract — refactor behind a translation layer rather than breaking consumers.

**Why this matters:** Making illegal states unrepresentable shifts a class of runtime bugs to compile time — the type IS the invariant.

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Making Impossible States Impossible — Richard Feldman](https://www.youtube.com/watch?v=IcgmSRJHu_8)
