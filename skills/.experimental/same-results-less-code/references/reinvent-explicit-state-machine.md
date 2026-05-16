---
title: Surface an Explicit State Machine Instead of Boolean Flag Juggling
impact: CRITICAL
impactDescription: 4-8 boolean flags collapsed to a single tagged state; eliminates impossible-state bugs
tags: reinvent, state-machine, modelling, discriminated-union
---

## Surface an Explicit State Machine Instead of Boolean Flag Juggling

When a component or service has more than two booleans tracking "lifecycle" — `isLoading`, `isReady`, `hasError`, `isSubmitting`, `isComplete` — they are *almost always* one variable in disguise. The flag form requires every reader to memorise the legal combinations and every writer to update multiple flags in lockstep. Modelling the same thing as a tagged union or state-machine library (XState, `useReducer`, a sealed Kotlin/Rust enum) replaces a thicket of `if`/`&&` with one switch.

**Incorrect (a boolean cartesian product with most combinations illegal):**

```typescript
function CheckoutButton() {
  const [isLoading, setIsLoading] = useState(false);
  const [isError, setIsError] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Anywhere this state is read:
  if (isLoading && !isError) { /* ... */ }
  if (isSubmitting && isError) { /* huh, can this happen? */ }
  if (isSuccess && isLoading) { /* surely not, but the type allows it */ }
  // 2^4 = 16 combinations. About 4 are valid. The rest are bugs waiting to happen.
}
```

**Correct (one variable, one switch, no illegal states):**

```typescript
type CheckoutState =
  | { kind: 'idle' }
  | { kind: 'submitting' }
  | { kind: 'success'; orderId: string }
  | { kind: 'error'; message: string };

function CheckoutButton() {
  const [state, setState] = useState<CheckoutState>({ kind: 'idle' });

  switch (state.kind) {
    case 'idle':       return <Button onClick={submit}>Pay</Button>;
    case 'submitting': return <Spinner />;
    case 'success':    return <Confirmation id={state.orderId} />;
    case 'error':      return <Error msg={state.message} onRetry={retry} />;
  }
  // 4 states, all reachable, all valid. No "is success and loading" trap.
  // `orderId` only exists in `success` — the type makes it impossible to read it elsewhere.
}
```

**Cues that you're looking at a hidden state machine:**

- Three or more `useState(false)` calls or `private boolean` fields in one place.
- Comments like `// don't set isLoading if hasError`.
- Conditional rendering chains of the form `isA && !isB && !isC && ...`.
- Logic to "reset" a group of flags together in the same handler.

**When NOT to use this pattern:**

- A single boolean for a genuinely orthogonal concern (e.g. `isDirty` independent of submission state) — keep it.
- Two booleans where the cartesian product is genuinely 4 valid states (rare).

Reference: [Make Illegal States Unrepresentable](https://blog.janestreet.com/effective-ml-revisited/) (Yaron Minsky)
