---
title: Await the value, then parse — z.promise() is deprecated
tags: dep, async, deprecated-api
---

## Await the value, then parse — z.promise() is deprecated

The wrong default is wrapping a schema in `z.promise()` to validate async results. zod@4 deprecated it — the changelog's own words are that there is rarely a reason to use it. A promise schema defers validation to an implicit `.then`, which hides *when* validation happens and forces `parseAsync` everywhere. Awaiting first keeps the parse synchronous and the failure point visible.

**Evidence of violation:** `z.promise(` anywhere in the target.

**Incorrect (deprecated — validation point is hidden inside the promise):**

```ts
const PendingUser = z.promise(z.object({ id: z.uuid() }))
const user = await PendingUser.parseAsync(fetchUser())
```

**Correct (await, then parse the settled value):**

```ts
const User = z.object({ id: z.uuid() })
const user = User.parse(await fetchUser())
```

Reference: [Zod 4 changelog — z.promise() deprecation](https://zod.dev/v4/changelog)
