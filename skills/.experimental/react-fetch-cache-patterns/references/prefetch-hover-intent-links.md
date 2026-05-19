---
title: Prefetch Links on Hover and Intent
impact: HIGH
impactDescription: 100-300ms faster perceived navigation
tags: prefetch, hover, intent, links, navigation
---

## Prefetch Links on Hover and Intent

Users take 100-300ms between hovering a link and clicking it. That's enough time to fire the next page's data and chunk fetch — by the time the click registers, the data is already in cache and the navigation is instant. Even better: prefetch on `pointerdown` (intent signal that beats `click` by ~80ms).

Next.js `<Link>` and TanStack Router do this automatically. For custom navigation, wire it explicitly with `onMouseEnter` / `onPointerDown`.

**Incorrect (link click → wait for chunk + data):**

```tsx
function ProductLink({ id, name }: { id: string; name: string }) {
  return <a href={`/product/${id}`}>{name}</a>;
  // Click → chunk download (200ms) → data fetch (300ms) → render → 500ms perceived wait
}
```

**Correct (prefetch on hover/intent):**

```tsx
function ProductLink({ id, name }: { id: string; name: string }) {
  const queryClient = useQueryClient();

  const prefetch = () =>
    queryClient.prefetchQuery({
      queryKey: productKeys.detail(id),
      queryFn: () => fetchProduct(id),
      staleTime: 30_000,
    });

  return (
    <a
      href={`/product/${id}`}
      onMouseEnter={prefetch}
      onPointerDown={prefetch}
    >
      {name}
    </a>
  );
  // Hover ~150ms before click → fetch already in flight when click registers
}
```

**With Next.js Link (automatic):**

```tsx
import Link from 'next/link';
<Link href={`/product/${id}`} prefetch={true}>{name}</Link>
// Prefetches route + data in viewport (auto) or on hover (with prefetch={true})
```

**With TanStack Router (automatic):**

```tsx
import { Link } from '@tanstack/react-router';
<Link to="/product/$id" params={{ id }} preload="intent">{name}</Link>
// preload: "intent" prefetches on hover/focus
```

**When NOT to prefetch:**
- Mobile (no hover) — prefetch on visible-in-viewport via IntersectionObserver instead
- Low-confidence destinations (e.g. a tag cloud where users rarely click each tag) — prefetching every one wastes bandwidth
- Authenticated endpoints when the user might not be authorized — wasted server work

**Mind the bandwidth budget:** prefetching N nearby links of M kb each means N×M kb downloaded even if the user clicks none. Limit to high-confidence (current viewport, primary CTAs).

Reference: [Next.js — Link Prefetching](https://nextjs.org/docs/app/api-reference/components/link#prefetch) | [TanStack Router — Preloading](https://tanstack.com/router/latest/docs/framework/react/guide/preloading)
