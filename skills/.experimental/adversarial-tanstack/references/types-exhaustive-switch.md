---
title: Check switches over discriminated unions for exhaustiveness
tags: types, discriminated-union, never, exhaustiveness
---

## Check switches over discriminated unions for exhaustiveness

The wrong default is ending a switch over a tagged union with `default: break` (or no default). That compiles today and silently no-ops the day a new variant joins the union — the compiler has no reason to flag the switch. Binding the default case to `never` turns "forgot a variant" into a compile error at the switch itself. Three equivalent forms pass: a `never`-typed binding, `satisfies never` (TS 4.9+), or an `assertNever()` helper call.

**Evidence of violation:** a `switch` over a discriminated union of two or more members whose `default` clause contains no `never` check — or which omits `default` while not returning from every case.

**Incorrect (adding a 'refunded' status later changes nothing here):**

```ts
function statusLabel(status: OrderStatus): string {
  switch (status.kind) {
    case 'pending': return 'Pending'
    case 'shipped': return 'Shipped'
    default: return 'Unknown'
  }
}
```

**Correct (a new variant is a compile error at this switch):**

```ts
function statusLabel(status: OrderStatus): string {
  switch (status.kind) {
    case 'pending': return 'Pending'
    case 'shipped': return 'Shipped'
    default:
      status satisfies never
      throw new Error(`Unhandled status: ${JSON.stringify(status)}`)
  }
}
```

Reference: [TypeScript Handbook — Exhaustiveness Checking](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
