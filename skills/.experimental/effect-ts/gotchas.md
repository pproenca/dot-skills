# Gotchas

### Effect.gen generators require `yield*` not `yield`
Effect generators use `yield*` (delegating yield) to unwrap effects. Using plain `yield` produces
type errors and incorrect behavior. This is the most common mistake when writing Effect code.
```ts
// Wrong
const program = Effect.gen(function* () {
  const user = yield getUser(id) // TypeError
})

// Correct
const program = Effect.gen(function* () {
  const user = yield* getUser(id)
})
```
Added: 2026-03

### Schema.decode vs Schema.decodeUnknown
`Schema.decode` expects input matching the `Encoded` type (already partially typed).
`Schema.decodeUnknownSync` / `Schema.decodeUnknownEither` accept `unknown` input, which is
what you want for parsing external data (API responses, form data, env vars).
Added: 2026-03

### Layer.provide order matters for composition
When providing multiple layers, dependencies must be provided before the layers that need them.
Use `Layer.merge` for independent layers and `Layer.provide` to pipe a dependency into a consumer.
```ts
// ConfigLive has no dependencies, DbLive depends on Config
const AppLive = DbLive.pipe(Layer.provide(ConfigLive))
```
Added: 2026-03

### Effect is lazy — nothing runs until you call runPromise/runSync
Unlike Promises which execute eagerly on construction, Effect values are descriptions of
computations. They don't execute until you explicitly run them with `Effect.runPromise`,
`Effect.runSync`, etc. This is by design but surprises Promise developers.
Added: 2026-03

### pipe vs .pipe — both work, choose one style
`pipe(value, fn1, fn2)` (import from "effect") and `value.pipe(fn1, fn2)` are equivalent.
The fluent `.pipe` style reads top-to-bottom and is generally preferred. Don't mix styles
within the same codebase.
Added: 2026-03

No further gotchas yet. Append entries as they're discovered during use.
