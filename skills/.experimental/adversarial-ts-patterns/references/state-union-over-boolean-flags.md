---
title: Model mutually exclusive lifecycles as one discriminated union, not boolean flags
tags: state, discriminated-union, impossible-states, react
---

## Model mutually exclusive lifecycles as one discriminated union, not boolean flags

The wrong default is accreting one boolean per condition — `isLoading`, `isError`, `isSuccess` — for a lifecycle whose states are mutually exclusive. Two booleans encode four representable combinations for at most three legal states; every added flag doubles the illegal state space, and the "can't happen" combination (`isLoading && isError`) eventually happens after a missed reset. A single discriminated union makes the illegal combinations unrepresentable, so the compiler — not a runtime guard — rules them out.

**Evidence of violation:** two or more boolean fields (or `useState<boolean>` calls) in one type, store slice, or component that encode a single mutually exclusive lifecycle — request status, wizard progress, connection state. The tell is that no legal path sets two of them true at once. Independent booleans that genuinely vary independently (e.g. `isMuted` and `isFullscreen`) are not violations.

**Incorrect (four representable combinations, three legal):**

```ts
type CheckoutState = {
  isSubmitting: boolean
  isError: boolean
  errorMessage?: string
  confirmationId?: string
}
// { isSubmitting: true, isError: true } compiles; so does a
// confirmationId alongside an errorMessage.
```

**Correct (illegal combinations do not compile):**

```ts
type CheckoutState =
  | { status: "idle" }
  | { status: "submitting" }
  | { status: "error"; errorMessage: string }
  | { status: "confirmed"; confirmationId: string }
// errorMessage exists only in the error state; narrowing on
// status gives each branch exactly its own data.
```

Reference: [react.dev — Choosing the State Structure (avoid contradictions in state)](https://react.dev/learn/choosing-the-state-structure#avoid-contradictions-in-state)
