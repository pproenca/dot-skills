---
title: Keep SSR render output deterministic
tags: ssr, hydration, nondeterminism, client-only
---

## Keep SSR render output deterministic

The wrong default is reading `new Date()`, `Math.random()`, `window`, or `navigator` directly in a component's render body. On an SSR'd route the server and client evaluate that expression at different moments (or the server lacks the API entirely), the outputs differ, and React reports a hydration mismatch — discarding the server-rendered tree or crashing. Client-only values enter render state through `useEffect`, the `useHydrated()` hook, or a `<ClientOnly>` boundary, all of which render a stable placeholder on the server and first client pass.

**Evidence of violation:** a direct `Date.now()`, `new Date()`, `Math.random()`, `window.*`, or `navigator.*` read inside a component render body (not inside `useEffect` or an event handler), in a route whose `ssr` option is not `false`.

**Incorrect (server and client render different strings):**

```tsx
function OrderFooter({ order }: { order: Order }) {
  return <time>Rendered at {new Date().toLocaleString()}</time>
}
```

**Correct (server renders the placeholder; the client fills in after hydration):**

```tsx
function OrderFooter({ order }: { order: Order }) {
  const [renderedAt, setRenderedAt] = useState<string>()
  useEffect(() => setRenderedAt(new Date().toLocaleString()), [])
  return <time>{renderedAt ?? '…'}</time>
}
```

Reference: [TanStack Start — Execution Model](https://tanstack.com/start/latest/docs/framework/react/guide/execution-model)
