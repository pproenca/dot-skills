---
title: Match discriminated unions exhaustively with a never check
tags: state, exhaustiveness, never, discriminated-union
---

## Match discriminated unions exhaustively with a never check

The wrong default is a `switch` over a discriminated union with a silent `default` (or an `if`/`else` chain with a catch-all) — it compiles today and keeps compiling when a new union member is added, routing the new state into whatever the fallback does. The value of modeling states as a union is that adding a member breaks every match that has not handled it; a swallowing `default` forfeits exactly that guarantee. Close every match with an assertion that the remaining value is `never`, so unhandled members become compile errors instead of runtime surprises.

**Evidence of violation:** a `switch` or `if`/`else` chain over a discriminated union that either omits members without a `never`-typed exhaustiveness check, or has a `default`/final `else` that returns a fallback value instead of asserting `never`. The carve-out is a union sourced from an external schema that is documented (in a comment at the match site) as open-ended — there, an explicit fallback branch is the correct handling of unknown members.

**Incorrect (new member silently falls through):**

```ts
function statusLabel(state: CheckoutState): string {
  switch (state.status) {
    case "submitting": return "Processing…"
    case "confirmed":  return "Done"
    default:           return ""   // "error" — and every future state — renders blank
  }
}
```

**Correct (adding a member breaks the build here):**

```ts
function assertNever(value: never): never {
  throw new Error(`Unhandled state: ${JSON.stringify(value)}`)
}

function statusLabel(state: CheckoutState): string {
  switch (state.status) {
    case "idle":       return ""
    case "submitting": return "Processing…"
    case "error":      return state.errorMessage
    case "confirmed":  return "Done"
    default:           return assertNever(state)
  }
}
```

Reference: [TypeScript Handbook — Narrowing (exhaustiveness checking)](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
