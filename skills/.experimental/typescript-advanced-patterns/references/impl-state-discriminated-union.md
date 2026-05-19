---
title: Model Workflow State as a Discriminated Union of State Records
impact: MEDIUM-HIGH
impactDescription: prevents 100% of illegal-state-combination bugs (loading + error simultaneously, success + no data)
tags: impl, state, discriminated-unions, modeling
---

## Model Workflow State as a Discriminated Union of State Records

The classic "loading / error / data" state object is almost always wrong: each field is independently nullable, so the type permits illegal combinations (loading and error true at the same time, data present while still loading). Modelling state as a discriminated *union of records* — one record per legal state, each carrying exactly the data that state has — makes illegal combinations un-typable. Components and reducers narrow on the tag and access only the fields valid for that tag. This is the structural-typing answer to "make impossible states impossible."

**Incorrect (independently nullable fields — combinatorial illegal states):**

```typescript
interface UserDetailState {
  isLoading: boolean
  user: User | null
  error: Error | null
}

function render(state: UserDetailState) {
  if (state.isLoading) return <Spinner />
  if (state.error) return <ErrorBanner error={state.error} />
  if (state.user) return <UserCard user={state.user} />
  return null

  // Compiles, but {isLoading: true, error: someError, user: someUser} is also a valid value.
  // Reducer bugs let it happen. Render is full of `if (state.user)` checks because TS
  // can't tell from isLoading=false that user is non-null.
}
```

**Correct (one record per legal state — illegal combinations un-typable):**

```typescript
type UserDetailState =
  | { status: 'idle' }
  | { status: 'loading'; userId: string }
  | { status: 'error'; userId: string; error: Error }
  | { status: 'success'; user: User }

function render(state: UserDetailState) {
  switch (state.status) {
    case 'idle':    return <EmptyState />
    case 'loading': return <Spinner label={`Loading user ${state.userId}`} />
    case 'error':   return <ErrorBanner error={state.error} onRetry={() => /* … */} />
    case 'success': return <UserCard user={state.user} />
                    //                 ^ user is User, not User | null
  }
}
```

The "tag" key is conventionally `status`, `kind`, `type`, or `state` — pick one for the codebase and stay consistent. The compiler narrows in `switch`, `if` chains, and pattern-matching libraries.

Three implementation rules that pay off in practice:

1. **Each state carries only what it needs.** Don't put `user` in `loading` "just in case the previous user is still there" — model that as a separate state (`refreshing` with both `previousUser` and `userId`) if it matters.
2. **Transitions are reducer cases.** `dispatch({ type: 'fetch', userId })` switches on the current `state.status` and the action; only valid transitions return a new state. Invalid combinations return the state unchanged.
3. **Persist by serialising the union directly** — the discriminant goes to JSON cleanly, and a Zod/Valibot schema can re-parse it on load (`[[dsl-schema-first-inference]]`).

**When NOT to apply:**
- Forms with many independent fields where each field is genuinely optional — modeling every combination is combinatorial. Use a flat shape with field-level validity instead.
- States with very few distinguishing fields — `{ status: 'open' | 'closed'; closedAt?: Date }` is fine; promoting it to a full union is over-engineering.

**Scope delta:**
- `typescript-refactor`'s `arch-discriminated-unions` covers the syntactic pattern. This rule covers the *modeling discipline* — when to choose a union over a flat record, how to handle transitions, and how illegal-state-prevention compounds across a component tree.

Reference: [TypeScript Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
