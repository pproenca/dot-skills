---
title: Stop Guarding Against States the Type or Flow Already Rules Out
impact: MEDIUM
impactDescription: eliminates defensive checks for states the type system guarantees impossible
tags: defense, types, narrowing, impossible-states
---

## Stop Guarding Against States the Type or Flow Already Rules Out

Defensive code becomes noise when it checks for things that *cannot* happen. `if (x === true)` for a value typed `boolean` already known to be `true`. A null check after a non-null assertion. A try/catch around code that never throws. An `else` branch in a switch over a closed union. Each one is a confidence symbol — "I don't trust the types" — and each makes the code longer without ruling out a bug that was already ruled out elsewhere.

**Incorrect (a small constellation of defensive noise):**

```typescript
function logActiveUser(user: User | null): void {
  if (user === null || user === undefined) return;
  if (!user) return;                                     // same check, again
  if (typeof user !== 'object') return;                  // the type says it's an object
  if (user.email === undefined) return;                  // email is `string`, not `string | undefined`
  if (user.email === null) return;                       // same
  if (user.status === 'active' && user.status !== 'inactive') {  // the second half is implied by the first
    if (user.active === true) {                          // `active` is `boolean`, already known to be true
      console.log(user.email);
    }
  }
}
```

**Correct (rely on the type system; only check what's actually uncertain):**

```typescript
function logActiveUser(user: User | null): void {
  if (!user) return;
  if (user.status === 'active') console.log(user.email);
}
// Two checks. Both ask real questions: is the user there, and is the user active.
// The rest was paranoia about states the type system already rules out.
```

**Common cases:**

| Defensive form | Why it's redundant |
|----------------|--------------------|
| `if (x === true)` for `x: boolean` | `if (x)` already says the same |
| `if (x === false)` for `x: boolean` | `if (!x)` already says the same |
| `if (x !== null && x !== undefined)` for `x: T` (no `\| null`) | The type says it's never null |
| `try { return JSON.parse(json) } catch { return null }` for `json` you just produced | Your own JSON.stringify output won't throw |
| Default branch in `switch (x: 'a' \| 'b' \| 'c')` covering all three | Exhaustiveness check beats the runtime guard |
| `if (Array.isArray(x))` for `x: string[]` | The type says it's an array |

**Exhaustiveness — the right way to be paranoid:**

```typescript
type Shape = { kind: 'circle'; r: number } | { kind: 'square'; side: number };

function area(s: Shape): number {
  switch (s.kind) {
    case 'circle': return Math.PI * s.r ** 2;
    case 'square': return s.side ** 2;
    default: {
      const _exhaustive: never = s;  // compile error if a new kind is added without a case
      return _exhaustive;
    }
  }
}
// The default isn't defensive against runtime; it's a compile-time alarm.
// Far stronger than `throw new Error('unknown shape')` at runtime.
```

**When NOT to use this pattern:**

- You're at a **trust boundary** — parsing user input, deserialising network/disk data, FFI calls into untyped code. The type system can't help; defensive checks are the right answer. (See [`types-validation-at-boundary`](types-parse-dont-validate.md) for how to do this once and narrow.)
- The type system *says* a value is non-null but you're inside an `any`/`unknown` cast you can't avoid — keep the check, and consider whether the cast is the real bug.
- A library author writing a public API that consumers might call wrong from JS — defensive checks earn their keep as friendly errors. (Add them at the boundary, not in every internal call.)

Reference: [TypeScript Handbook — Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html); [Make Illegal States Unrepresentable](https://blog.janestreet.com/effective-ml-revisited/)
