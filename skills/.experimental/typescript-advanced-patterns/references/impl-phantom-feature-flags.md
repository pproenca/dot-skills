---
title: Gate Feature-Dependent Code with Phantom Capability Types
impact: MEDIUM-HIGH
impactDescription: prevents 100% of "forgot the flag check" bugs at gated code sites; lets the type system enforce the gate
tags: impl, feature-flags, phantom-types, capabilities, type-safety
---

## Gate Feature-Dependent Code with Phantom Capability Types

Feature flags are usually a `boolean` checked inline (`if (flags.newCheckout) {...}`). The boolean is fine, but the *consumers* of the new feature have no type-level proof the check ran — a refactor that drops the `if` compiles silently, and dead code paths that "couldn't happen with the flag off" sometimes do. Tagging the flag's truth with a phantom type, and requiring downstream functions to take that phantom-tagged value, makes the gate part of the type contract. This combines `[[mod-phantom-capability-tracking]]` with the specific feature-flag use case so the gate cannot be forgotten.

**Incorrect (boolean checked in some places, forgotten in others):**

```typescript
interface Flags { newCheckout: boolean; betaUI: boolean }

function renderCheckout(flags: Flags, cart: Cart) {
  if (flags.newCheckout) {
    return <NewCheckout cart={cart} discountEngine={loadDiscountEngine()} />
  }
  return <LegacyCheckout cart={cart} />
}

function applyDiscount(cart: Cart, code: string) {
  // forgot to check flags.newCheckout — discount engine called from legacy path crashes
  const engine = loadDiscountEngine()
  return engine.apply(cart, code)
}
```

**Correct (flag check produces a phantom-typed value that gates downstream functions):**

```typescript
declare const __flagOn: unique symbol
type FlagOn<F extends string> = { readonly [__flagOn]: F }

interface Flags {
  newCheckout: boolean
  betaUI: boolean
}

function check<F extends keyof Flags>(flags: Flags, flag: F): (FlagOn<F> | null) {
  return flags[flag] ? ({} as FlagOn<F>) : null
}

// Functions that depend on the flag take proof in their signature.
function loadDiscountEngine(proof: FlagOn<'newCheckout'>): DiscountEngine {
  // Body cannot run without proof. The proof itself carries no runtime data —
  // it exists only at the type level. Caller cannot fabricate it without `check`.
  return new DiscountEngine()
}

function applyDiscount(cart: Cart, code: string, proof: FlagOn<'newCheckout'>) {
  return loadDiscountEngine(proof).apply(cart, code)
}

function renderCheckout(flags: Flags, cart: Cart) {
  const proof = check(flags, 'newCheckout')
  if (proof) {
    return <NewCheckout cart={cart} engine={loadDiscountEngine(proof)} />
  }
  return <LegacyCheckout cart={cart} />
}

// At any other call site:
applyDiscount(cart, 'PROMO')  // Error: missing FlagOn<'newCheckout'>.
// To call it, the developer must call `check(flags, 'newCheckout')` first.
```

The phantom type adds zero runtime cost — the returned object is `{}` typed as `FlagOn<F>`. The only way to manufacture one is to call `check`, which encapsulates the actual boolean test. Forgetting the check becomes a compile error at the gated call site, with a useful message pointing at the missing capability.

**When NOT to apply:**
- Flags that gate UI rendering only (show/hide a button). The boolean is enough; the cost of phantom typing exceeds the benefit.
- Flags whose state changes mid-render or mid-request (kill switches that flip during a session). The phantom proof becomes stale; rely on runtime checks at each use.
- Internal kill-switch infrastructure where the type discipline doesn't propagate to consumers (binary-flag feature systems).

**Scope delta:**
- Applies `[[mod-phantom-capability-tracking]]` to the feature-flag domain specifically. The general capability rule explains the mechanism; this rule explains *which* capabilities feature flags benefit from encoding and where the boundary functions live.

Reference: [Martin Fowler — Feature Toggles](https://martinfowler.com/articles/feature-toggles.html)
