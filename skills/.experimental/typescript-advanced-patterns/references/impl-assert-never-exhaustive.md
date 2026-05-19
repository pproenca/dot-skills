---
title: Use `assertNever` to Force Exhaustive Handling of Union Variants
impact: MEDIUM-HIGH
impactDescription: prevents 100% of "added variant, forgot a handler" regressions across the codebase
tags: impl, exhaustive, never, assertions, refactor-safety
---

## Use `assertNever` to Force Exhaustive Handling of Union Variants

A `switch` over a discriminated union compiles even when cases are missing — it just falls through, returns `undefined`, or hits the `default`. The compiler can verify exhaustiveness, but only if the final fallthrough is *typed* as `never`. The `assertNever` helper formalises this: pass it the discriminated value at the unreachable end of the switch, and the type system errors at every call site that adds a new variant without updating the handler. This is the most cost-effective refactor-safety technique in the whole rule set — three lines of helper code save hours of grep-and-fix.

**Incorrect (no exhaustive check — silent miss when a variant is added):**

```typescript
type Notification =
  | { kind: 'email'; to: string; subject: string }
  | { kind: 'sms'; to: string; body: string }
  | { kind: 'push'; deviceToken: string; payload: object }

function send(n: Notification) {
  switch (n.kind) {
    case 'email': return sendEmail(n.to, n.subject)
    case 'sms':   return sendSms(n.to, n.body)
    // forgot 'push' — silent fall-through, function returns undefined.
  }
}

// Later, someone adds:
// type Notification = ... | { kind: 'slack'; channel: string; text: string }
// Every switch in the codebase that doesn't handle 'slack' silently passes through.
```

**Correct (`assertNever` at the unreachable branch):**

```typescript
function assertNever(value: never): never {
  throw new Error(`unhandled variant: ${JSON.stringify(value)}`)
}

function send(n: Notification) {
  switch (n.kind) {
    case 'email': return sendEmail(n.to, n.subject)
    case 'sms':   return sendSms(n.to, n.body)
    case 'push':  return sendPush(n.deviceToken, n.payload)
    default: return assertNever(n)  // n is `never` here — all variants accounted for
  }
}

// Now add { kind: 'slack'; ... } to Notification:
// Error at `send`: Argument of type 'Notification' is not assignable to parameter of type 'never'.
//   Type '{ kind: "slack"; channel: string; text: string }' is not assignable to type 'never'.
```

`tsc` lights up every switch in the codebase that doesn't handle the new variant. The error message names the unhandled variant directly.

Three places `assertNever` pays off beyond switches:

```typescript
// 1. If-chains on discriminants
if      (s.status === 'idle')    { /* … */ }
else if (s.status === 'loading') { /* … */ }
else if (s.status === 'success') { /* … */ }
else { assertNever(s) }  // forces 'error' case to be added

// 2. Object-literal dispatch tables
const handlers: Record<Notification['kind'], (n: Notification) => void> = {
  email: (n) => { /* … */ },
  sms:   (n) => { /* … */ },
  push:  (n) => { /* … */ },
  // Missing 'slack' is an immediate error on the Record's keys.
}

// 3. After narrowing on a tag chain
function describe(n: Notification): string {
  if (n.kind === 'email') return `email to ${n.to}`
  if (n.kind === 'sms')   return `sms to ${n.to}`
  if (n.kind === 'push')  return `push to ${n.deviceToken}`
  return assertNever(n)
}
```

**When NOT to apply:**
- Switches on open unions (`string`, `number`, anything not closed) — `assertNever` would always fail because the type can't be narrowed to `never`. Use a `default` case that handles unknown values instead.
- Library boundaries where the union may legitimately grow externally — exhaustive switches force every minor version bump into a major. Use a default with a typed fallback instead.

**Scope delta:**
- `typescript-refactor`'s `narrow-exhaustive-switch` introduces the idea. This rule covers the *full kit* — the helper definition, the three usage shapes (switch, if-chain, dispatch record), and the refactor-safety guarantee. `assertNever` is the cheapest type-level safety net in TypeScript and frequently the missing piece in codebases that have everything else right.

Reference: [TypeScript Handbook — Exhaustiveness Checking](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
