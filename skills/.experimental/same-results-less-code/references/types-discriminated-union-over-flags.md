---
title: Use a Discriminated Union Instead of Optional Fields and Runtime Tags
impact: LOW-MEDIUM
impactDescription: eliminates manual tag checks; reduces 5-10 lines of guards to a switch
tags: types, discriminated-union, modelling
---

## Use a Discriminated Union Instead of Optional Fields and Runtime Tags

When a value has several distinct "shapes" — `success` vs `error`, `loading` vs `loaded` vs `failed` — modelling it as one type with optional fields forces every reader to check which fields are set this time. A discriminated union (also called a tagged union or sum type) makes each shape its own variant with exactly the fields it needs. The type system then proves that you accessed only legal fields per case, and the reader can switch over the variants.

**Incorrect (one shape with optional fields; manual runtime checks everywhere):**

```typescript
type ApiResult = {
  loading: boolean;
  data?: User;
  error?: string;
};

function render(result: ApiResult) {
  if (result.loading) return <Spinner />;
  if (result.error)   return <Error msg={result.error} />;
  if (result.data)    return <UserCard user={result.data} />;
  // What does it mean if loading=false, error=undefined, data=undefined? Nothing legal.
  // What if loading=true, data=someUser? Allowed by the type. Should not be.
  return <Empty />;                                       // a default no caller meant
}
```

**Correct (each variant carries exactly its fields; switch exhausts the cases):**

```typescript
type ApiResult =
  | { kind: 'loading' }
  | { kind: 'success'; data: User }
  | { kind: 'error';   message: string };

function render(result: ApiResult) {
  switch (result.kind) {
    case 'loading': return <Spinner />;
    case 'error':   return <Error msg={result.message} />;
    case 'success': return <UserCard user={result.data} />;
  }
  // `result.data` is only accessible inside `success`.
  // `result.message` is only accessible inside `error`.
  // Adding a new variant → TypeScript flags the switch as non-exhaustive.
  // No `Empty` default needed — there is no fourth state.
}
```

**The discriminant is whatever distinguishes the cases:**

- `kind: 'a' | 'b'` (most common) — pick `kind`, `type`, `status`, or `_tag`. Be consistent within the codebase.
- An existing string enum is a natural discriminant — don't add a parallel one.
- For numeric variants or boolean discriminants, ensure the type is genuinely a literal (`true | false`, not `boolean`).

**Common cases that want discriminated unions:**

- Result types: `Ok<T> | Err<E>` (or libraries: `neverthrow`, `oxide.ts`, `effect-ts`).
- API states: `idle | loading | success | error`.
- Form fields: `empty | typing | validating | valid | invalid`.
- Payment methods: `card | bank | wallet`, each with its own fields.
- Notification types where each kind carries different payload (`message`, `mention`, `system`).

**Symptoms:**

- A type with many optional fields where "which ones are set together" is documented in comments, not types.
- A function whose body is `if (x.foo) ... else if (x.bar) ...` — `foo`/`bar` are case markers in disguise.
- Tests asserting "if `loading` is true, `data` should be undefined" — that's a type invariant, not a test.
- Default branches in switches that handle "shouldn't happen" cases.

**When NOT to use this pattern:**

- The "variants" are genuinely independent attributes that combine freely (e.g. `archived: boolean` and `pinned: boolean` — both true means archived AND pinned). Keep them as flags.
- The data shape comes from an external system you don't control — model the union at the boundary after parsing, even if the wire format is flat.

Reference: [TypeScript Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
