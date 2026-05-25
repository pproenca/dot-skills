---
title: Place Suspense boundaries around the dynamic leaf, not the page
tags: shell, suspense, granularity, static-shell
---

## Place Suspense boundaries around the dynamic leaf, not the page

The model wraps the whole page (or a large layout region) in one `<Suspense>`. That collapses the static shell down to just the fallback — you lose the instant-shell benefit PPR exists for, and a single slow dependency blocks the entire view. Push each boundary as low as possible, around the specific component that reads dynamic data, so the maximum amount of surrounding UI stays static and ships immediately.

**Incorrect (boundary too high — almost nothing is static):**

```tsx
export default function ProductPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header /> {/* static, but now trapped behind the boundary */}
      <ProductInfo /> {/* static */}
      <LiveInventory /> {/* the only genuinely dynamic part */}
    </Suspense>
  )
}
```

**Correct (boundary around the dynamic leaf only):**

```tsx
export default function ProductPage() {
  return (
    <>
      <Header />
      <ProductInfo />
      <Suspense fallback={<InventorySkeleton />}>
        <LiveInventory />
      </Suspense>
    </>
  )
}
```

Reference: [Caching — putting it all together](https://nextjs.org/docs/app/getting-started/caching#putting-it-all-together)
