---
title: Subscribe to shared types through a cached snapshot
tags: react, usesyncexternalstore, rendering, hooks
---

## Subscribe to shared types through a cached snapshot

Yjs publishes no React binding — `yjs/y-react` exists as an empty repository that has never received a commit, and the community packages are years without a release — so this hook is the application's to write, and the obvious implementation breaks. `useSyncExternalStore` requires that "while the store has not changed, repeated calls to `getSnapshot` must return the same value," but `toJSON()` and `toArray()` build a fresh object on every call. React compares with `Object.is`, sees a change every render, and throws: *The result of getSnapshot should be cached to avoid an infinite loop*. Yjs types are mutated in place, so there is no version counter to lean on either — the snapshot has to be cached and invalidated explicitly when the type changes.

**Incorrect (new reference every call, infinite render loop):**

```tsx
const tasks = useSyncExternalStore(
  (onChange) => { yTasks.observeDeep(onChange); return () => yTasks.unobserveDeep(onChange) },
  () => yTasks.toJSON(), // fresh array each call
)
```

**Correct (snapshot rebuilt only when the type actually changes):**

```tsx
// `AbstractType<any>` is deliberate — the private `_eH` field makes the type
// parameter invariant, so `AbstractType<unknown>` rejects Y.Map, Y.Array and Y.Text alike.
export function useYSnapshot<T>(type: Y.AbstractType<any>, read: () => T): T {
  const cache = useRef<{ value: T } | null>(null)

  const subscribe = useCallback(
    (onChange: () => void) => {
      const handler = () => {
        cache.current = null // invalidate, then let React re-read
        onChange()
      }
      type.observeDeep(handler)
      return () => type.unobserveDeep(handler)
    },
    [type],
  )

  const getSnapshot = useCallback(() => {
    cache.current ??= { value: read() }
    return cache.current.value
  }, [type])

  return useSyncExternalStore(subscribe, getSnapshot, getSnapshot)
}
```

```tsx
const tasks = useYSnapshot(yTasks, () => yTasks.toJSON() as Task[])
```

The third argument is `getServerSnapshot`, and omitting it is not optional in Next.js — React's reference states that "if you omit this argument, rendering the component on the server will throw an error." Passing the same reader works when the document is empty during server render, which it is whenever the provider only connects on the client; pass a separately serialized initial state if the server renders real content.

One consequence of caching worth knowing: the cache is invalidated only by Yjs events, so `read` must not close over props that change independently. Keep `read` a pure function of the shared type, and derive anything prop-dependent from the returned snapshot during render.

Reference: [React — useSyncExternalStore](https://react.dev/reference/react/useSyncExternalStore)
