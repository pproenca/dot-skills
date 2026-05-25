---
title: Pass dynamic children and Server Actions through a cached component
tags: cache, use-cache, composition, children
---

## Pass dynamic children and Server Actions through a cached component

The model assumes `'use cache'` on a wrapper caches *everything* rendered inside it, so it avoids wrapping any dynamic UI — or it tries to call a passed-in Server Action inside the cached body. Neither is right: a cached component can receive `children` (and Server Actions) and pass them through untouched without affecting its cache entry, **as long as it doesn't introspect or invoke them**. This is how you keep a cached shell wrapped around dynamic content, or render a form whose action is dynamic, without losing the cache.

```tsx
async function CachedShell({
  children,
  publish,
}: {
  children: React.ReactNode
  publish: () => Promise<void>
}) {
  'use cache'
  const nav = await getNav() // cached
  return (
    <div>
      <SiteNav items={nav} />
      {children} {/* passed through — not cached, never introspected */}
      <PublishButton action={publish} /> {/* action passed through, never called here */}
    </div>
  )
}
```

Reference: [use cache — interleaving](https://nextjs.org/docs/app/api-reference/directives/use-cache#interleaving)
