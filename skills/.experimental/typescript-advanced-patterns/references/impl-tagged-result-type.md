---
title: Model Operation Outcomes as `Ok<T> | Err<E>` Tagged Unions
impact: MEDIUM-HIGH
impactDescription: forces 100% of error paths to be handled at the call site; eliminates `throw`-based control flow
tags: impl, result, discriminated-unions, error-handling, exhaustive
---

## Model Operation Outcomes as `Ok<T> | Err<E>` Tagged Unions

Throwing for failure conditions makes errors invisible at the function signature. The caller cannot tell which calls might fail, what errors they produce, or whether they have been handled. A tagged `Result<T, E>` makes the failure shape part of the signature: every consumer either narrows on the tag or gets a compile error. This is not the same as wrapping every function in try/catch — `Result` is for *expected* failures (validation, not-found, business rule violations); throws remain for *unexpected* failures (out-of-memory, programmer errors). Done right, the distinction makes both kinds easier to handle.

**Incorrect (throws hide failure modes from the signature):**

```typescript
function findUser(id: string): User {
  const row = db.query('SELECT * FROM users WHERE id = ?', [id])
  if (!row) throw new NotFoundError(id)
  if (row.deletedAt) throw new GoneError(id)
  return row
}

// At the call site:
const user = findUser('u_42')  // No hint that this throws. No hint of which errors. No exhaustive handling.
```

**Correct (tagged result with exhaustive handling at call site):**

```typescript
type Ok<T>  = { readonly tag: 'ok'; readonly value: T }
type Err<E> = { readonly tag: 'err'; readonly error: E }
type Result<T, E> = Ok<T> | Err<E>

const ok  = <T>(value: T): Ok<T>   => ({ tag: 'ok', value })
const err = <E>(error: E): Err<E> => ({ tag: 'err', error })

type FindUserError =
  | { kind: 'notFound'; id: string }
  | { kind: 'gone'; id: string; deletedAt: Date }

function findUser(id: string): Result<User, FindUserError> {
  const row = db.query('SELECT * FROM users WHERE id = ?', [id])
  if (!row) return err({ kind: 'notFound', id })
  if (row.deletedAt) return err({ kind: 'gone', id, deletedAt: row.deletedAt })
  return ok(row)
}

// At the call site:
const result = findUser('u_42')
if (result.tag === 'err') {
  switch (result.error.kind) {
    case 'notFound': return new Response('Not found', { status: 404 })
    case 'gone':     return new Response('Gone', { status: 410 })
    // Missing case ⇒ assertNever forces it to be added (see `[[impl-assert-never-exhaustive]]`)
  }
}
const user = result.value  // narrowed to User
```

Two design rules that make `Result` pay off:

1. **The error type is a discriminated union per concrete failure mode** — never `string` or `Error`. The discriminant (`kind`) lets the call site pattern-match.
2. **Boundary functions translate `Result` to whatever the framework wants** (HTTP response, throw, Slack message). Keep the `Result` discipline inside the business layer; convert at the edge.

Composition — chain `Result`s without nested `if` ladders:

```typescript
function mapResult<T, U, E>(r: Result<T, E>, f: (t: T) => U): Result<U, E> {
  return r.tag === 'ok' ? ok(f(r.value)) : r
}
function chainResult<T, U, E1, E2>(r: Result<T, E1>, f: (t: T) => Result<U, E2>): Result<U, E1 | E2> {
  return r.tag === 'ok' ? f(r.value) : r
}
```

**When NOT to apply:**
- Functions whose only failure mode is programmer error or impossible-in-practice — throwing is shorter and clearer.
- When a downstream framework (Express handler, GraphQL resolver) already wraps everything in try/catch — wrapping again with `Result` doubles the layering for no gain.

**Scope delta:**
- `typescript-refactor`'s `error-result-type` covers the basic idea (using an `ok: true/false` shape). This rule uses an alternative `tag: 'ok' | 'err'` discriminator, adds the discriminated-error pattern, the composition helpers, and the rule about where the boundary translation happens. Either shape is fine — pick one per codebase and stay consistent.

Reference: [TypeScript Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
