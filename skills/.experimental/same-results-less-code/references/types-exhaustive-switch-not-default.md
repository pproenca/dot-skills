---
title: Use Exhaustiveness Checks Instead of a Catch-All default
impact: LOW-MEDIUM
impactDescription: prevents silent fall-through; eliminates the "I added a case and forgot to handle it" bug class
tags: types, exhaustive, switch, never
---

## Use Exhaustiveness Checks Instead of a Catch-All default

A `default` branch in a `switch` over a discriminated union or literal union usually means one of two things: (1) the engineer is handling a runtime-impossible case "just in case" (defensive excess — see [`defense-guard-against-impossible`](defense-guard-against-impossible.md)), or (2) the engineer is silently fall-through-handling future cases that haven't been added yet. Replace the `default` with an exhaustiveness check using `never`, and the compiler will flag every place that needs updating when the union grows.

**Incorrect (silent default that handles future variants without you knowing):**

```typescript
type PaymentMethod = 'card' | 'bank' | 'wallet';

function processingFee(method: PaymentMethod): number {
  switch (method) {
    case 'card':   return 0.029;
    case 'bank':   return 0.008;
    case 'wallet': return 0.015;
    default:       return 0;                              // silently returns 0 for any new variant
  }
}

// Six months later: someone adds 'crypto' to PaymentMethod.
// Every switch in the codebase that handled the old three now silently returns 0 for crypto.
// No compile error. The bug is "we lost $X in crypto fees this quarter."
```

**Correct (exhaustiveness check turns the gap into a compile error):**

```typescript
type PaymentMethod = 'card' | 'bank' | 'wallet';

function processingFee(method: PaymentMethod): number {
  switch (method) {
    case 'card':   return 0.029;
    case 'bank':   return 0.008;
    case 'wallet': return 0.015;
  }
  // No default — the switch covers all three cases. TS infers `never` after the switch.
}

// Or, more explicit with an assertNever helper:
function assertNever(x: never): never {
  throw new Error(`Unhandled variant: ${JSON.stringify(x)}`);
}

function processingFee(method: PaymentMethod): number {
  switch (method) {
    case 'card':   return 0.029;
    case 'bank':   return 0.008;
    case 'wallet': return 0.015;
    default:       return assertNever(method);            // compile error when PaymentMethod grows
  }
}
// Adding 'crypto' → TypeScript errors at this line. No silent fall-through.
```

**The same trick for if-chains over discriminated unions:**

```typescript
type Event = { kind: 'click' } | { kind: 'submit' } | { kind: 'change' };

function describe(e: Event): string {
  if (e.kind === 'click')  return 'clicked';
  if (e.kind === 'submit') return 'submitted';
  if (e.kind === 'change') return 'changed';

  const _exhaustive: never = e;                            // compile error if a new kind appears
  return _exhaustive;
}
```

**When NOT to use this pattern:**

- The input genuinely is `string` (not a literal union) — you need a default for unknown values. But ask first: should the input be a union? See [`types-literal-union-over-string`](types-literal-union-over-string.md).
- The default isn't a fallthrough but a deliberate "for all other cases, do X" — that's a real branch. Be explicit: `default: return DEFAULT_FEE;` is fine if `DEFAULT_FEE` is documented as the policy. The smell is when `default` returns a sentinel that hides bugs (`return 0`, `return null`).
- You're consuming an external API where new values may appear without your code knowing — defending with a default is reasonable. Log unknown values rather than silently swallowing.

**Symptoms:**

- A `default` in a switch over a closed union, returning a sentinel value.
- A bug ticket pattern: "after we added X to the enum, Y didn't pick it up."
- Adding a variant requires grepping for every existing switch to update — exhaustiveness checks turn that into compile errors.

Reference: [TypeScript Handbook — Exhaustiveness Checking](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
